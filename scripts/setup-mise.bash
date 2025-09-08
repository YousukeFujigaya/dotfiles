#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"

###########################################################
# Options
###########################################################
for i in "$@"; do
    case "$i" in
    -s | --skip-update)
        skip_update=1
        shift
        ;;
    *) ;;
    esac
done

###########################################################
# Install mise
###########################################################
if command -v mise >/dev/null 2>&1; then
    log "mise is already installed."
else
    log "Installing mise via homebrew..."
    brew install mise
fi

# -------------------------------------------------------------------------
### Install plugins and tools from .tool-versions
if [ -f ~/.tool-versions ]; then
    log "Installing tools from .tool-versions..."
    
    # Install all tools specified in .tool-versions
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        tool=$(echo "$line" | awk '{print $1}')
        version=$(echo "$line" | awk '{print $2}')
        
        if [ -n "$tool" ] && [ -n "$version" ]; then
            log "Installing $tool@$version..."
            mise install "$tool@$version" || log "Warning: Failed to install $tool@$version"
        fi
    done < ~/.tool-versions
    
    # Set global versions
    log "Setting global tool versions..."
    mise install
fi

###########################################################
# Yarn global
###########################################################
# if ! is_dir ~/.config/yarn/global/node_modules; then
#     log 'Setup Yarn global'
#     yarn global add
# fi

# -------------------------------------------------------------------------
### Updating
[[ "$skip_update" == 1 ]] && exit

log "Updating mise..."
mise self-update || log "Warning: mise self-update failed (may not be supported on this installation method)"

log "Updating mise plugins..."
mise plugins update

log "Installing/updating tools from .tool-versions..."
if [ -f ~/.tool-versions ]; then
    mise install
fi
