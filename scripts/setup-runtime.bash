#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if command -v rtx >/dev/null 2>&1; then
    if is_file "$HOME/.local/bin/setup-rtx.bash"; then
        /bin/bash "$HOME/.local/bin/setup-rtx.bash"
    else
        /bin/bash "$CUR_DIR/setup-rtx.bash"
    fi
else
    if is_file "$HOME/.local/bin/setup-asdf.bash"; then
        /bin/bash "$HOME/.local/bin/setup-asdf.bash"
    else
        /bin/bash "$CUR_DIR/setup-asdf.bash"
    fi
fi
