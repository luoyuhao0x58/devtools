#! /usr/bin/bash
set -uexo pipefail


export $(cat "$BUILD_CONSTANTS_PATH" | grep '=' | xargs)
source "$BUILD_UTILS_PATH"

build_env_var_names="$(get_build_env_var_names $BUILD_CONSTANTS_PATH)"

# 修改系统默认镜像源
sed -i "s/deb.debian.org/${MIRROR_APT}/g" /etc/apt/sources.list.d/debian.sources
apt-get update -y
apt-get install -y apt-transport-https ca-certificates apt-utils tzdata locales
sed -i "s/http/https/g" /etc/apt/sources.list.d/debian.sources


# 配置系统语言和时区等本地化信息
echo "${LANG} UTF-8" >/etc/locale.gen
echo "LANG='${LANG}'" >>/etc/default/locale
printf "\nexport LANG=${LANG}\n" >>/etc/profile
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure locales tzdata


# 升级镜像和安装必要的系统工具
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  sudo lsb-release psmisc inotify-tools sysstat \
  man-db source-highlight \
  openssh-server netcat-openbsd net-tools iproute2 iputils-ping lsof dnsutils telnet \
  curl wget rsync \
  zip unzip unrar-free p7zip-full \
  file tree jq less\
  git subversion \
  screen tmux \
  vim-nox emacs-nox \
  build-essential manpages-dev python3-dev python3-venv python3-pip python-is-python3 pipx

# 配置系统免密提权
sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

update-alternatives --set editor /usr/bin/vim.nox

# configure git
git config --system core.quotepath false
git config --system color.ui auto
git config --system pull.ff only
git config --system pull.rebase true
git config --system init.defaultbranch main
git config --system credential.helper store

useradd -d $DEVCONTAINER_USER_HOME -s /bin/bash -g staff -G sudo -N -m -u $DEVCONTAINER_USER_ID \
  -p $(tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c8) $DEVCONTAINER_USER_NAME

# 同步默认的静态文件
rsync -a --ignore-times "$BUILD_DIR/common/rootfs/" /
chown "${DEVCONTAINER_USER_NAME}:staff" -R "$BUILD_DIR/common/dotfiles"
rsync -a --ignore-times "$BUILD_DIR/common/dotfiles/" "${DEVCONTAINER_USER_HOME}/"

# history setting
sed -r -i -e '/^[[:space:]]*(HISTFILESIZE|HISTCONTROL|HISTSIZE|HISTTIMEFORMAT)=/d' /etc/skel/.bashrc
echo 'export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S]  "' > /etc/profile.d/history.sh

# limits setting
echo '*               soft    nofile          65535
*               hard    nofile          65535
root            soft    nofile          65535
root            hard    nofile          65535
root            soft    core            unlimited
root            hard    core            unlimited' > /etc/security/limits.conf

echo 'runtime! debian.vim
set nocompatible
set background=dark
set laststatus=2
set showmode
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set mouse=""
set nobackup
set backspace=indent,eol,start' > /etc/vim/vimrc.local

ln -sf /bin/bash /bin/sh

# 构建前其他服务工具的安装
for filename in $(ls $BUILD_DIR/stage1/*_*.sh | sort); do
  sudo -u ${DEVCONTAINER_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$filename"
done