#! /bin/bash
set -uexo pipefail

versions=$@

curl -sSfL "$MIRROR_RUST_RUSTUP_INIT_SCRIPT" | bash -s -- -y

cat >>~/.profile <<EOF

# rustup
export RUSTUP_UPDATE_ROOT='$MIRROR_RUST_RUSTUP_UPDATE_ROOT'
export RUSTUP_DIST_SERVER='$MIRROR_RUST_RUSTUP_DIST_SERVER'
export PATH="\$HOME/.cargo/bin:\$PATH"
EOF

mkdir -p ~/.cargo
source_name=$(echo "$MIRROR_RUST_CRATES" | cut -d'.' -f 2)
cat >~/.cargo/config.toml <<EOF
[source.crates-io]
replace-with = '$source_name'
[source.$source_name]
registry = "sparse+$MIRROR_RUST_CRATES"
[registries.$source_name]
index = "sparse+$MIRROR_RUST_CRATES"
EOF

source ~/.profile
for version in $versions; do
  rustup install $version
done
rustup default $version