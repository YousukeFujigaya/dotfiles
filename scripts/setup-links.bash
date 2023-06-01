#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

DOTFILES_HOME="$GHQ_ROOT_PATH"/github.com/"$GITHUB_USER_NAME"/dotfiles
STOW_PACKAGES_PATH="$DOTFILES_HOME"/packages

###########################################################
# Options
###########################################################
unlink_packages=()
for i in "$@"; do
    case "$i" in
    -u | --unlink)
        shift
        while [[ "$1" != -* && ! -z "$1" ]]; do
            if [[ "$1" != "-u" && "$1" != "--unlink" ]]; then
                unlink_packages+=("$1")
            fi
            shift
        done
        ;;
    -uall | --unlink-all)
        unlink_all=1
        shift
        ;;
    *) ;;
    esac
done

###########################################################
# Unlink
###########################################################
if [ ${#unlink_packages[@]} -gt 0 ]; then
    for package in "${unlink_packages[@]}"; do
        log "Unlinking packages: $package"
        stow -vD -d "$STOW_PACKAGES_PATH" -t ~ "$package"
    done
    exit
fi

if [ "$unlink_all" = 1 ]; then
    submodules=$(awk '/path/ {print $3}' "$DOTFILES_HOME/.gitmodules" | sed 's|.*/||')
    full_paths="$(fd --hidden --no-ignore -t f -H -I -E "$submodules" -E "zsh" . "$STOW_PACKAGES_PATH")"

    unlink_packages=()
    for packages in "$full_paths"; do
        unlink_packages=($(echo "$full_paths" | sed -n 's|.*/packages/\([^/]*\)/.*|\1|p'))
        unlink_packages+=("$unlink_packages") # TODO: 配列に重複がある
    done

    log 'Unlinking all packages...'
    for package in "${unlink_packages[@]}"; do
        stow -vD -d "$STOW_PACKAGES_PATH" -t "$HOME" "$package"
    done
    # -------------------------------------------------------------------------
    log 'Unlinking scripts...'

    unlink_script_paths=($(find "${DOTFILES_HOME}/scripts" -type f -exec basename {} \;))
    for script_name in "${unlink_script_paths[@]}"; do
        rm "$HOME/.local/bin/$script_name"
    done

    exit
fi

##########################################################
# link
##########################################################
### mkdir
make_dir=(
    "$XDG_CONFIG_HOME"
    "$XDG_STATE_HOME"
    "$XDG_CACHE_HOME"
    "$XDG_CONFIG_HOME/zsh"
)
for dir in "${make_dir[@]}"; do
    ensure_dir "$dir"
done

# ensure_dir "$HOME/.ssh"
# chmod 700 "$HOME/.ssh"

# ensure_dir "$HOME/.gnupg"
# chmod 700 "$HOME/.gnupg"

### Stow link ###
log 'Linking packages...'
stow -vd "$STOW_PACKAGES_PATH" -t "$HOME" $(ls $STOW_PACKAGES_PATH)

# -------------------------------------------------------------------------
log 'Linking scripts...'
ensure_dir "$HOME/.local/bin"
ln -sfv "$DOTFILES_HOME/scripts/"* "$HOME/.local/bin"

# -------------------------------------------------------------------------
