#! /usr/bin/bash
set -uexo pipefail

export $(cat "$BUILD_DIR/constants.cfg" | grep '=' | xargs)
source "$BUILD_DIR/utils.sh"

build_env_var_names="$(get_build_env_var_names $BUILD_DIR/constants.cfg)"

declare -A configs
for CONFIG in $(echo $CROSSDEV_BUILD_CONFIGS | xargs -d';'); do
  type=$(echo $CONFIG | cut -d ':' -f 1)
  versions=$(echo $CONFIG | cut -d ':' -f 2- | sed 's/:/ /')
  configs[$type]=$versions
done
for module_name in $(ls "$BUILD_DIR/modules.d" | sort); do
  type=$(echo $module_name | cut -d '_' -f 2)
  set +u
  versions="${configs[$type]}"
  set -u
  if [ ! -z "${versions}" ]; then
    sudo -u ${CROSSDEV_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$BUILD_DIR/modules.d/$module_name/main.sh" $(echo ${versions} | xargs -d',')
  fi
done

for filename in $(ls "$BUILD_DIR/hooks.d/after_build" | sort); do
  sudo -u ${CROSSDEV_USER_NAME} --preserve-env="$build_env_var_names" /usr/bin/bash -uexo pipefail "$BUILD_DIR/hooks.d/after_build/$filename"
done