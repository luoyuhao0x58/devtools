#! /usr/bin/bash
set -uexo pipefail

export $(cat "$BUILD_CONSTANTS_PATH" | grep '=' | xargs)
source "$BUILD_UTILS_PATH"

build_env_var_names="$(get_build_env_var_names $BUILD_CONSTANTS_PATH)"

apt-get update -y

for filename in $(ls $BUILD_DIR/stage3/*_*.sh | sort); do
  sudo -u ${DEVCONTAINER_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$filename"
done