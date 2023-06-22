#!/usr/bin/env bash

set -eu
# shellcheck source=./scripts/common.bash

source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if is_file "$HOME/.local/bin/setup.bash"; then
    log "load scripts in $HOME/.local/bin"

    /bin/bash "$HOME/.local/bin/setup-homebrew.bash"
    /bin/bash "$HOME/.local/bin/setup-apt.bash"
    /bin/bash "$HOME/.local/bin/setup-links.bash"
    /bin/bash "$HOME/.local/bin/setup-runtime.bash"
    /bin/bash "$HOME/.local/bin/setup-zinit.bash"
    /bin/bash "$HOME/.local/bin/setup-nvim.bash"
    /bin/bash "$HOME/.local/bin/setup-login.bash"

else
    /bin/bash "$CUR_DIR/macos-defaults.sh"
    /bin/bash "$CUR_DIR/setup-homebrew.bash"
    /bin/bash "$CUR_DIR/setup-apt.bash"
    /bin/bash "$CUR_DIR/setup-links.bash"
    /bin/bash "$CUR_DIR/setup-runtime.bash"
    /bin/bash "$CUR_DIR/setup-zinit.bash"
    /bin/bash "$CUR_DIR/setup-nvim.bash"
    /bin/bash "$CUR_DIR/setup-login.bash"
fi

echo ✨ All Done!
