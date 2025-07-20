#! /bin/bash
set -uexo pipefail

source "$BUILD_UTILS_PATH"

# 构建前端开发环境
versions=$@

# https://github.com/nvm-sh/nvm?tab=readme-ov-file#manual-install

# 安装nvm
export NVM_DIR="$HOME/.nvm" && (
  gitclone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

# 配置nvm
cat <<'EOF' >>~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

# 安装node
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#use-a-mirror-of-node-binaries
source ~/.bashrc
for version in $versions; do
  NVM_NODEJS_ORG_MIRROR="$MIRROR_NODEJS_BIN" nvm install $version
done
nvm use $version
npm config set registry "$MIRROR_NODEJS_REGISTRY"
npm install -g yarn
npm cache clean --force
nvm cache clear
