#!/usr/bin/env bash

GITHUB_USER_NAME="YousukeFujigaya"
GHQ_ROOT_PATH="$HOME/Repos"

export CUR_DIR REPO_DIR
CUR_DIR="$(
    cd "$(dirname "$0")" || exit 1
    pwd
)"
REPO_DIR="$(
    cd "$(dirname "$0")/.." || exit 1
    pwd
)"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
