
get_build_env_var_names() {
  local constants_vars=$(
    grep -E '^[[:alnum:]_]+=' "$1" |
    cut -d= -f1 |
    tr '\n' ',' |
    sed 's/,$//'
  )
  echo "DEBIAN_FRONTEND,LANG,BUILD_DIR,BUILD_TMP_DIR,BUILD_UTILS_PATH,BUILD_CONSTANTS_PATH,DEVCONTAINER_USER_ID,DEVCONTAINER_USER_NAME,DEVCONTAINER_USER_HOME,DEVCONTAINER_BUILD_CONFIGS,${constants_vars}"
}

get_default_cflags() {
  local arch="$(dpkg-architecture --query DEB_BUILD_ARCH)"
  if [[ "$arch" == 'amd64' ]]; then
    # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
    echo '-march=x86-64 -mtune=generic'
  elif [[ "$arch" == 'arm64' ]]; then
    # https://gcc.gnu.org/onlinedocs/gcc/AArch64-Options.html
    echo '-march=armv8-a -mtune=generic'
  else
    echo '-march=native -mtune=native'
  fi
}

version_compare() {
    local v=$1 op=$2 target=$3
    local -a av at i

    # 分割版本号并补全到相同长度
    while IFS= read -d. -r part; do
        av+=("$part")
    done <<< "$v."
    while IFS= read -d. -r part; do
        at+=("$part")
    done <<< "$target."

    # 补全较短数组
    for ((i=${#av[@]}; i<${#at[@]}; i++)); do av[i]=0; done
    for ((i=${#at[@]}; i<${#av[@]}; i++)); do at[i]=0; done

    # 逐段比较
    for ((i=0; i<${#av[@]}; i++)); do
        if (( av[i] > at[i] )); then
            case "$op" in
                '>'|'>='|'!=') return 0 ;;
                '<'|'<='|'==') return 1 ;;
            esac
        elif (( av[i] < at[i] )); then
            case "$op" in
                '<'|'<='|'!=') return 0 ;;
                '>'|'>='|'==') return 1 ;;
            esac
        fi
    done

    # 所有段都相等时的处理
    case "$op" in
        '=='|'>='|'<=') return 0 ;;
        '!='|'>'|'<')  return 1 ;;
    esac
}


gitclone() {
  local GIT_REPO="$1"
  local GIT_DIR="$2"

  if [ -z $GIT_DIR ]; then
    GIT_DIR=$(basename $GIT_REPO)
    GIT_DIR=${GIT_DIR%.git}
  fi

  local URL="$GIT_REPO"
  if [ ! "$MIRROR_GITHUB" = '' ]; then
    URL="$MIRROR_GITHUB/${GIT_REPO#https://}"
  fi
  git clone --depth=1 "$URL" "$GIT_DIR"
  if [ ! "$MIRROR_GITHUB" = '' ]; then
    (cd "$GIT_DIR" && git remote set-url origin "$GIT_REPO")
  fi
}