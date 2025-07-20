JAVA_ROOT_PATH=/opt/java/jvm
if [ ! -d "$JAVA_ROOT_PATH" ]; then
  sudo mkdir -p "$JAVA_ROOT_PATH"
fi

function java_install() {
  local v=$1

  echo "Install Java SDK $v from Huawei Mirror:"
  m=$(uname -m)
  if [[ "$m" == 'x86_64' ]]; then
    m=x64
  fi
  local fname="openjdk-${v}_linux-${m}_bin.tar.gz"
  curl -L "$MIRROR_JAVA_BIN/openjdk/$v/$fname" -o "$fname"
  local jhome=$(sudo tar xvf "$fname" -C "${JAVA_ROOT_PATH}/" | sed -e 's@/.*@@' | uniq)
  jenv add "$JAVA_ROOT_PATH/$jhome" && rm -rf "$fname"
}