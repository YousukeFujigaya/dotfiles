#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if command -v mise >/dev/null 2>&1; then
    if is_file "$HOME/.local/bin/setup-mise.bash"; then
        /bin/bash "$HOME/.local/bin/setup-mise.bash"
    else
        /bin/bash "$CUR_DIR/setup-mise.bash"
    fi
else
    log "mise is not installed. Please install mise first."
    exit 1
fi
