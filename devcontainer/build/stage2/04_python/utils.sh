download_python() {
  local version=$1
  curl -L "$MIRROR_PYTHON_BIN/python/$version/Python-$version.tar.xz" -o ~/.pyenv/cache/Python-$version.tar.xz
}

install_openssl() {
   local version="$1"
   local target_path="/opt/openssl@$version"

   if [ ! -d "$target_path" ]; then
      wget "$MIRROR_GITHUB/https://github.com/openssl/openssl/releases/download/OpenSSL_$(echo "$version" | sed 's/\./_/g')/openssl-$version.tar.gz"
      tar xzf "openssl-$version.tar.gz"

      (cd "openssl-$version" ; ./config --prefix="$target_path" --openssldir="$target_path/ssl" -fPIC no-shared zlib-dynamic && make -j$(nproc) && sudo make install)
   fi
}