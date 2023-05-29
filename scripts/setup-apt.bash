#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash

source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if ! command -v apt-get >/dev/null; then
    log 'command apt-get is not found.'
    echo 'skip setup-apt.bash'
    exit 0
else
    log 'command apt-get is found in this computer.'
fi

[ -n "$SKIP_APT" ] && log 'skip setup-apt.bash' && exit

log 'Installing Apps and CLIs...'
sudo /bin/sh "$REPO_DIR/apt/install.sh"
