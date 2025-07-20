#! /usr/bin/bash
set -uexo pipefail

sudo curl -fsSL "https://github.com/mvdan/sh/releases/download/v${VERSION_SHFMT}/shfmt_v${VERSION_SHFMT}_linux_$(dpkg-architecture --query DEB_BUILD_ARCH)" -o /usr/local/bin/shfmt
sudo chmod a+x /usr/local/bin/shfmt