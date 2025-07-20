#! /bin/bash
set -uexo pipefail

source "$BUILD_UTILS_PATH"

GIT_REPO=https://github.com/ohmybash/oh-my-bash.git
gitclone $GIT_REPO ~/.oh-my-bash

cat <<'EOF' >>~/.bashrc

# oh my bash
export OSH=~/.oh-my-bash
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
OMB_USE_SUDO=false
completions=(
  git
  ssh
  tmux
  system
  docker
  docker-compose
  uv
)
aliases=(
  general
)
plugins=(
  sudo git
)
[ "$SSH_TTY" ] && plugins+=(tmux-autoattach)
EOF

echo 'source "$OSH/oh-my-bash.sh"' >>~/.bashrc
