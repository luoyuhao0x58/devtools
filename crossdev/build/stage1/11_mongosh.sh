#! /usr/bin/bash
set -uexo pipefail

version='8.0'

curl -fsSL "https://www.mongodb.org/static/pgp/server-$version.asc" | \
   sudo gpg -o "/usr/share/keyrings/mongodb-server-$version.gpg" \
   --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-$version.gpg ] $MIRROR_MONGODB/apt/debian $(. /etc/os-release && echo "$VERSION_CODENAME")/mongodb-org/$version main" | sudo tee "/etc/apt/sources.list.d/mongodb-org-$version.list"

sudo apt-get -y update
sudo apt-get install -y mongodb-mongosh