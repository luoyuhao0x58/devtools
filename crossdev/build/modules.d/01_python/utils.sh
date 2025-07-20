download_python() {
  local version=$1
  curl -L "$MIRROR_PYTHON_EXECUTABLE_FILE/python/$version/Python-$version.tar.xz" -o ~/.pyenv/cache/Python-$version.tar.xz
}