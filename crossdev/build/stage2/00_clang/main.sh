versions=$@
# set +u
# sudo wget https://apt.llvm.org/llvm.sh
# sudo chmod a+x llvm.sh
# for version in $versions; do
#   sudo ./llvm.sh "$version" -m "$MIRROR_LLVM"
# done
# set -u
# sudo rm llvm.sh

sudo apt-get install -y llvm-${versions} clang-${versions}