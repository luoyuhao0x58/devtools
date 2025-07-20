#! /bin/bash
set -uexo pipefail

versions=$@

source "$BUILD_DIR/utils.sh"

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/utils.sh"

# install python dependence
# llvm installed by 00.cpp.sh
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  libbluetooth-dev uuid-dev

# install pyenv
GIT_REPO=https://github.com/pyenv/pyenv.git
gitclone "$GIT_REPO" ~/.pyenv
mkdir ~/.pyenv/cache/
(cd ~/.pyenv && src/configure && make -C src)


# arch="$(dpkg-architecture --query DEB_BUILD_ARCH)"
# export PYTHON_CFLAGS='-march=native -mtune=native'
# BASE_PYTHON_CONFIGURE_OPTS="--enable-loadable-sqlite-extensions --enable-optimizations --enable-option-checking=fatal --with-lto --with-ensurepip --enable-shared"


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

# install python
source ~/.profile
for version in $versions; do
  download_python $version
  pyenv install $version
  pyenv rehash
  if version_compare "$version" '<' "3"; then
    ("$(pyenv root)/versions/$version/bin/python" -m pip install --upgrade pip virtualenv)
  fi
done
pyenv global $version

python -m pip config set global.index-url "$MIRROR_PYTHON_PYPI"

# install poetry
if version_compare "$version" '>' "3.6"; then
  python -m pip install pipx
  python -m pipx install poetry

  # configure poetry
  source ~/.profile
  poetry config virtualenvs.in-project true
fi


# clear
python -m pip cache purge
rm -rf ~/.pyenv/cache/*
