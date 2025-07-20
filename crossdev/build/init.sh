#! /usr/bin/bash
set -uexo pipefail


export $(cat "$BUILD_DIR/constants.cfg" | grep '=' | xargs)
source "$BUILD_DIR/utils.sh"

build_env_var_names="$(get_build_env_var_names $BUILD_DIR/constants.cfg)"

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
  sudo software-properties-common psmisc inotify-tools sysstat python3-pip pipx \
  man-db source-highlight \
  netcat-openbsd net-tools iputils-ping lsof dnsutils telnet \
  curl wget rsync \
  zip unzip unrar-free p7zip-full \
  file tree jq less\
  git subversion \
  screen tmux \
  vim-nox emacs-nox \
  build-essential manpages-dev

# 配置系统免密提权
sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

# configure git
git config --system core.quotepath false
git config --system color.ui auto
git config --system pull.ff only
git config --system pull.rebase true
git config --system init.defaultbranch main
git config --system credential.helper store

useradd -d $CROSSDEV_USER_HOME -s /bin/bash -g staff -G sudo -N -m -u $CROSSDEV_USER_ID \
  -p $(tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c8) $CROSSDEV_USER_NAME

# 同步默认的静态文件
rsync -a --ignore-times ./rootfs/ /

# 构建前其他服务工具的安装
for filename in $(ls "$BUILD_DIR/hooks.d/before_build" | sort); do
  sudo -u ${CROSSDEV_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$BUILD_DIR/hooks.d/before_build/$filename"
done