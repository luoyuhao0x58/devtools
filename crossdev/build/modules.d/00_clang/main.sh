set +u
sudo wget -4 "${MIRROR_LLVM}/llvm.sh"
sudo chmod +x llvm.sh
sudo ./llvm.sh $VERSION_LLVM -m "$MIRROR_LLVM"
set -u
sudo rm llvm.sh