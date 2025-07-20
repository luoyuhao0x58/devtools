#! /bin/bash
set -uexo pipefail

versions=$@

cat >>~/.profile <<EOF

# rustup
export RUSTUP_UPDATE_ROOT='$MIRROR_RUST_RUSTUP_UPDATE_ROOT'
export RUSTUP_DIST_SERVER='$MIRROR_RUST_RUSTUP_DIST_SERVER'
export PATH="\$HOME/.cargo/bin:\$PATH"
EOF

source ~/.profile

curl -sSfL "$MIRROR_RUST_RUSTUP_INIT_SCRIPT" | bash -s -- -y

mkdir -p ~/.cargo
cat >~/.cargo/config.toml <<EOF
[source.crates-io]
replace-with = '$MIRROR_RUST_NAME'
[source.$MIRROR_RUST_NAME]
registry = "sparse+$MIRROR_RUST_CRATES"
[registries.$MIRROR_RUST_NAME]
index = "sparse+$MIRROR_RUST_CRATES_REGISTRY"
[net]
git-fetch-with-cli = true
EOF

source ~/.profile
for version in $versions; do
  rustup install $version
done
rustup default $version