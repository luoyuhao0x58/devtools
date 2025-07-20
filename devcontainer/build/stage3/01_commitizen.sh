#! /usr/bin/bash
set -uexo pipefail

if command -v pipx >/dev/null 2>&1; then
  pipx install commitizen
fi