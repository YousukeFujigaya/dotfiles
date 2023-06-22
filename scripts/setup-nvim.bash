#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash

source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if ! is_dir "$GHQ_ROOT_PATH/github.com/$GITHUB_USER_NAME/nvim"; then
    log "Clone Nvim Repository..."
    ghq get YousukeFujigaya/nvim
    ln -sfnv "$GHQ_ROOT_PATH/github.com/$GITHUB_USER_NAME/nvim" "$XDG_CONFIG_HOME/nvim"
elif is_dir "$GHQ_ROOT_PATH/github.com/$GITHUB_USER_NAME/nvim" && ! is_dir "$XDG_CONFIG_HOME/nvim"; then
    log "Linking Nvim Repository to $XDG_CONFIG_HOME ..."
    ln -sfnv "$GHQ_ROOT_PATH/github.com/$GITHUB_USER_NAME/nvim" "$XDG_CONFIG_HOME/nvim"
else
    log "Nvim Repository is already cloned."
    # log "Updating Nvim Repository..."
    # git -C "$GHQ_ROOT_PATH/github.com/$GITHUB_USER_NAME/nvim" pull
fi
