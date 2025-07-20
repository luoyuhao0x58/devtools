
get_build_env_var_names() {
  local constants_vars=$(
    grep -E '^[[:alnum:]_]+=' "$1" |
    cut -d= -f1 |
    tr '\n' ',' |
    sed 's/,$//'
  )
  echo "DEBIAN_FRONTEND,LANG,BUILD_DIR,CROSSDEV_USER_ID,CROSSDEV_USER_NAME,CROSSDEV_USER_HOME,CROSSDEV_BUILD_CONFIGS,${constants_vars}"
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
  GIT_REPO="$1"
  GIT_DIR="$2"

  if [ -z $GIT_DIR ]; then
    GIT_DIR=$(basename $GIT_REPO)
    GIT_DIR=${GIT_DIR%.git}
  fi
  git clone --depth=1 "$MIRROR_GIT/${GIT_REPO#https://}" "$GIT_DIR"
  (cd "$GIT_DIR" && git remote set-url origin "$GIT_REPO")
}