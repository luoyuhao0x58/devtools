#! /bin/bash
set -uexo pipefail

versions=$@

mkdir -p ~/.g/bin

arch="$(dpkg-architecture --query DEB_BUILD_ARCH)"
curl -L "$MIRROR_GITHUB/https://github.com/voidint/g/releases/download/v$VERSION_GOLANG_G/g$VERSION_GOLANG_G.linux-$arch.tar.gz" -o "g$VERSION_GOLANG_G.linux-$arch.tar.gz"
tar xzf "g$VERSION_GOLANG_G.linux-$arch.tar.gz" -C ~/.g/bin

cat >~/.g/env <<'EOF'
#!/bin/sh
# g shell setup
export GOROOT="${HOME}/.g/go"
[ -z "$GOPATH" ] && export GOPATH="${HOME}/go"
export PATH="${HOME}/.g/bin:${GOROOT}/bin:${GOPATH}/bin:$PATH"
export GOEXPERIMENT=jsonv2
EOF
echo "export G_MIRROR='$MIRROR_GOLANG_G'" >> ~/.g/env
echo "export GOPROXY='$MIRROR_GOLANG_GOPROXY,direct'" >> ~/.g/env

cat >>~/.bashrc <<'EOF'

# g config begin
if [[ -n $(alias g 2>/dev/null) ]]; then
    unalias g
fi
[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env"  # g shell setup
# g config end
EOF

set +u
source ~/.g/env
set -u

for version in $versions; do
  g install $version
done
g clean