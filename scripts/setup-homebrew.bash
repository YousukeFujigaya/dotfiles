#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

[ "$(uname)" != "Darwin" ] && log 'This machine is not macOS!' && exit
[ -n "$SKIP_HOMEBREW" ] && exit
export SKIP_APT="true"

###########################################################
# Options
###########################################################
verbose=
for i in "$@"; do
    case "$i" in
    -s | --skip-apps)
        skip_apps=1
        shift
        ;;
    -v | --verbose)
        verbose=1
        shift
        ;;
    -ud | --update)
        update_homebrew=1
        shift
        ;;
    *) ;;
    esac
done

###########################################################
# Install Homebrew
###########################################################
arch_name="$(uname -m)"

if type brew >/dev/null; then
    log "Homebrew is already installed."
else
    if [[ "${arch_name}" = "x86_64" && ! -f /usr/local/bin/brew ]]; then
        log 'Installing Homebrew...'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        export PATH="usr/local/bin:$PATH"
        log "Updating Homebrew..."
        brew update
    elif [[ "${arch_name}" = "arm64" && ! -f /opt/homebrew/bin/brew ]]; then
        log 'Installing Homebrew...'
        arch -arm64e /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        export PATH="/opt/homebrew/bin:$PATH"
        log "Updating Homebrew..."
        brew update
    fi
fi

if [ "$update_homebrew" ]; then
    log "Updating Homebrew..."
    brew update
fi

if [ ! "$skip_apps" ]; then
    log "Installing Apps and CLIs..."
    if is_file "${REPO_DIR}/homebrew/Brewfile"; then
        brew bundle install --file "${REPO_DIR}/homebrew/Brewfile" $([ -n "$verbose" ] && echo -v)
    else
        brew bundle install --file "${GHQ_ROOT_PATH}/github.com/${GITHUB_USER_NAME}/dotfiles/homebrew/Brewfile" $([ -n "$verbose" ] && echo -v)
    fi
fi

true
