#!/bin/sh
set -e

GITHUB_USER_NAME=YousukeFujigaya
GHQ_ROOT_PATH=~/Repos

INSTALL_DIR="${INSTALL_DIR:-${GHQ_ROOT_PATH}/github.com/${GITHUB_USER_NAME}/dotfiles}"

###########################################################
# Clone dotfiles from github.com
###########################################################
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📌 Clone dotfiles..."
    git clone https://github.com/"$GITHUB_USER_NAME"/dotfiles --recursive "$INSTALL_DIR"
else
    echo "📌 Updating dotfiles..."
    git -C "$INSTALL_DIR" pull
    [ -f "$INSTALL_DIR"/.gitmodule ] && git submodule update --init --recursive
fi

# ----------------------------------------------------------
/bin/bash "$INSTALL_DIR/scripts/setup.bash"
