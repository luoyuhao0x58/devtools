#! /bin/bash
set -uexo pipefail

versions=$@

source "$BUILD_UTILS_PATH"

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/utils.sh"

gitclone https://github.com/jenv/jenv.git ~/.jenv
echo 'export PATH="$HOME/.jenv/bin:$PATH"' >>~/.profile
echo 'eval "$(jenv init -)"' >>~/.profile

source ~/.profile
jenv enable-plugin export

for version in $versions; do
  java_install $version
done
jenv global $version