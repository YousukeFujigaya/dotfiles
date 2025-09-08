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
    --clean-broken)
        clean_broken=1
        shift
        ;;
    *) ;;
    esac
done

###########################################################
# Clean broken symlinks
###########################################################
if [ "$clean_broken" = 1 ]; then
    log 'Searching for broken symlinks in ~/.config...'
    
    # Find broken symlinks that point to dotfiles packages
    broken_links=()
    while IFS= read -r -d '' link; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            target=$(readlink "$link")
            # Check if the symlink points to our dotfiles packages
            if [[ "$target" == *"dotfiles/packages/"* ]]; then
                broken_links+=("$link")
            fi
        fi
    done < <(find "$HOME/.config" -type l -print0 2>/dev/null)
    
    if [ ${#broken_links[@]} -eq 0 ]; then
        log 'No broken symlinks found.'
        exit 0
    fi
    
    log "Found ${#broken_links[@]} broken symlinks:"
    for link in "${broken_links[@]}"; do
        target=$(readlink "$link")
        echo "  $link -> $target"
    done
    
    echo
    read -p "Do you want to remove these broken symlinks? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for link in "${broken_links[@]}"; do
            log "Removing broken symlink: $link"
            rm "$link"
        done
        log 'Broken symlinks removed successfully.'
    else
        log 'Skipped removing broken symlinks.'
    fi
    exit 0
fi

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

ensure_dir "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

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
