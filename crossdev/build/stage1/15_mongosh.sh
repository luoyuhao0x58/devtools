#! /usr/bin/bash
set -uexo pipefail

curl -fsSL "https://www.mongodb.org/static/pgp/server-$VERSION_MONGODB.asc" | \
   sudo gpg -o "/usr/share/keyrings/mongodb-server-$VERSION_MONGODB.gpg" \
   --dearmor

arch="$(dpkg-architecture --query DEB_BUILD_ARCH)"
if [[ "$arch" == 'amd64' ]]; then
   MIRROR_MONGODB="$MIRROR_MONGODB_AMD64"
else
   MIRROR_MONGODB="$MIRROR_MONGODB_ARM64"
fi
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-$VERSION_MONGODB.gpg ] $MIRROR_MONGODB/apt/debian $(. /etc/os-release && echo "$VERSION_CODENAME")/mongodb-org/$VERSION_MONGODB main" | sudo tee "/etc/apt/sources.list.d/mongodb-org-$VERSION_MONGODB.list"

sudo apt-get -y update
sudo apt-get install -y mongodb-mongosh