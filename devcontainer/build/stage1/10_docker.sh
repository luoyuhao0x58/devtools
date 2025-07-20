#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y docker-cli docker-compose docker-buildx

sudo groupadd docker
sudo usermod -aG docker $USER

echo 'alias docker="sudo docker"' >>~/.bashrc