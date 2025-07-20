#! /bin/bash
set -uexo pipefail

versions=$@

source "$BUILD_UTILS_PATH"

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/utils.sh"

# install python dependence
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev openssl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  libbluetooth-dev uuid-dev pipx

pip config set global.index-url "$MIRROR_PYTHON_PYPI"
pipx ensurepath
# poetry
pipx install poetry
pipx run poetry config virtualenvs.in-project true
# uv
pipx install uv ruff
pip cache purge

mkdir -p ~/.config/uv
echo 'link-mode = "copy"
add-bounds = "major"
cache-dir = "/tmp/uv_cache"
' > ~/.config/uv/uv.toml

# install pyenv
gitclone 'https://github.com/pyenv/pyenv.git' ~/.pyenv
mkdir ~/.pyenv/cache/
(cd ~/.pyenv && src/configure && make -C src)

# configure pyenv
sed -Ei -e '/^([^#]|$)/ {a \
export PYENV_ROOT="$HOME/.pyenv"
a \
export PATH="$PYENV_ROOT/bin:$PATH"
a \
' -e ':a' -e '$!{n;ba};}' ~/.profile
echo 'eval "$(pyenv init --path)"' >>~/.profile

cat <<'EOF' >>~/.bashrc

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF

install_python() {
  # https://docs.python.org/zh-cn/3.13/using/configure.html
  local v="$1"
  local configure_opts="$2"
  local cflag="$3"
  env PYTHON_CONFIGURE_OPTS="$configure_opts" PYTHON_CFLAGS="$cflag" pyenv install "$v"
}

# install python
source ~/.profile
for version in $versions; do
  download_python "$version"

  configure_opts='--enable-option-checking=fatal --with-ensurepip --enable-shared'
  cflag="$(get_default_cflags) -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"
  if version_compare "$version" '>=' '3.6'; then
    configure_opts="$configure_opts --enable-loadable-sqlite-extensions"
    cflag="$cflag -fno-semantic-interposition"
  fi
  if version_compare "$version" '>=' '3.8'; then
    configure_opts="$configure_opts --enable-optimizations --with-lto"
  fi
  if version_compare "$version" '>=' '3.13'; then
    configure_opts="$configure_opts --disable-gil --enable-experimental-jit"
  fi

  if version_compare "$version" '<' '3'; then
    # https://github.com/pyenv/pyenv/issues/3210#issuecomment-2704667237
    # https://github.com/pyenv/pyenv/wiki/Common-build-problems#error-the-python-ssl-extension-was-not-compiled-missing-the-openssl-lib
    openssl_backport_version='1.1.1w'
    openssl_backport_path="/opt/openssl@$openssl_backport_version"
    (cd /tmp ; install_openssl "$openssl_backport_version")
    configure_opts="$configure_opts --enable-optimizations --with-lto --with-system-ffi --enable-unicode=ucs4"
    echo "--- Modules/Setup.local	2025-09-04 19:07:09.672690436 +0800
+++ Modules/Setup.local	2025-09-04 19:06:35.916067974 +0800
@@ -0,0 +1,2 @@
+_ssl _ssl.c -I${openssl_backport_path}/include ${openssl_backport_path}/lib/libssl.a ${openssl_backport_path}/lib/libcrypto.a
+_hashlib _hashopenssl.c -I${openssl_backport_path}/include ${openssl_backport_path}/lib/libcrypto.a" > /tmp/py2.7.18.patch
    env PYTHON_CONFIGURE_OPTS="$configure_opts" PYTHON_CFLAGS="$cflag" LDFLAGS="-L$openssl_backport_path/lib" CPPFLAGS="-I$openssl_backport_path/include" pyenv install --patch "$version" < /tmp/py2.7.18.patch
    sudo rm -rf $openssl_backport_path
    python_executable_file_path="$(pyenv root)/versions/$version/bin/python"
    ("$python_executable_file_path" -m pip install --upgrade pip virtualenv wheel)
    ("$python_executable_file_path" -m pip cache purge)
  else
     install_python "$version" "$configure_opts" "$cflag"
  fi

  pyenv rehash
done
pyenv global system

# clear
rm -rf ~/.pyenv/cache/*