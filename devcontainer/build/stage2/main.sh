#! /usr/bin/bash
set -uexo pipefail

export $(cat "$BUILD_CONSTANTS_PATH" | grep '=' | xargs)
source "$BUILD_UTILS_PATH"

build_env_var_names="$(get_build_env_var_names $BUILD_CONSTANTS_PATH)"

apt-get update -y

declare -A configs
for CONFIG in $(echo $DEVCONTAINER_BUILD_CONFIGS | xargs -d':'); do
  type=$(echo $CONFIG | cut -d '@' -f 1)
  versions=$(echo $CONFIG | cut -d '@' -f 2- | sed 's/:/ /')
  configs[$type]=$versions
done
for filename in $(ls $BUILD_DIR/stage2/*_*/main.sh | sort); do
  folder_name=$(basename $(dirname $filename))
  type=$(echo $folder_name | cut -d '_' -f 2)
  set +u
  versions="${configs[$type]}"
  set -u
  if [ ! -z "${versions}" ]; then
    sudo -u ${DEVCONTAINER_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$filename" $(echo ${versions} | xargs -d',')
  fi
done