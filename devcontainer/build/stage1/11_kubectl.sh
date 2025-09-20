#! /usr/bin/bash
set -uexo pipefail

curl -fsSL "${MIRROR_K8S}/core/stable/v${VERSION_K8S}/deb/Release.key" |
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${MIRROR_K8S}/core/stable/v${VERSION_K8S}/deb/ /" |
    sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
