#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

if is_dir "$XDG_DATA_HOME/zinit/bin"; then
    log "zinit is already installed."
    log "update zinit"
    git -C "$XDG_DATA_HOME/zinit/bin" pull
else
    log "Installing zinit..."
    git clone "https://github.com/zdharma-continuum/zinit" "$GHQ_ROOT_PATH/github.com/zdharma-continuum/zinit"
    ensure_dir "$XDG_DATA_HOME/zinit"
    ln -sfnv "$GHQ_ROOT_PATH/github.com/zdharma-continuum/zinit" "$XDG_DATA_HOME/zinit/bin"
fi

source "$HOME/.zshenv" "$XDG_CONFIG_HOME/zsh/.zshrc"
