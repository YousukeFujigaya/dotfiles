#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

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
# Install asdf
###########################################################
if is_dir "$ASDF_DATA_DIR"; then
    log "asdf is already installed."
    # shellcheck source=/dev/null
    source "$ASDF_DATA_DIR/asdf.sh"

    # log "Updating asdf..."
    # asdf update
    # log "Updating asdf plugins..."
    # asdf plugin update --all

elif ! is_dir "$ASDF_DATA_DIR" && is_dir "$GHQ_ROOT_PATH/github.com/asdf-vm/asdf"; then
    log 'Linking asdf to $ASDF_DATA_DIR ...'
    ln -sfnv "$GHQ_ROOT_PATH/github.com/asdf-vm/asdf" "$ASDF_DATA_DIR"

    # shellcheck source=/dev/null
    source "$ASDF_DATA_DIR/asdf.sh"

else
    log "Installing asdf..."
    # git clone "https://github.com/asdf-vm/asdf" "$ASDF_DATA_DIR"
    git clone "https://github.com/asdf-vm/asdf" "$GHQ_ROOT_PATH/github.com/asdf-vm/asdf"
    # ghq get asdf-vm/asdf
    log 'Linking asdf to $ASDF_DATA_DIR ...'
    ln -sfnv "$GHQ_ROOT_PATH/github.com/asdf-vm/asdf" "$ASDF_DATA_DIR"

    # shellcheck source=/dev/null
    source "$ASDF_DATA_DIR/asdf.sh"

    # -------------------------------------------------------------------------
    ### Install plugins
    for plugin in $(awk '{print $1}' ~/.tool-versions); do
        if ! is_dir "$ASDF_DATA_DIR/plugins/$plugin"; then
            log "Installing asdf plugins: $plugin ..."
            asdf plugin add "$plugin"
        fi
    done

    is_runtime_versions_changed() {
        plugin="$1"
        specified=$(grep "$plugin" ~/.tool-versions | awk '{$1=""; print $0}')
        installed=$(asdf list "$plugin" 2>&1)

        is_changed=
        for version in $specified; do
            match=$(echo "$installed" | grep "$version")
            [ -z "$match" ] && is_changed=1
        done

        [ "$is_changed" ]
    }

    for plugin in $(asdf plugin list); do
        if is_runtime_versions_changed "$plugin"; then
            # if [ "$plugin" = nodejs ]; then log "Import release team keyring for Node.JS"
            #     bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
            # fi

            log "Install runtime: $plugin"
            asdf install "$plugin"
        fi
    done
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

log "Updating asdf..."
asdf update

log "Updating asdf plugins..."
asdf plugin update --all

for plugin in $(awk '{print $1}' ~/.tool-versions); do
    if ! is_dir "$ASDF_DATA_DIR/plugins/$plugin"; then
        log "Installing asdf plugins: $plugin ..."
        asdf plugin add "$plugin"
    fi
done

is_runtime_versions_changed() {
    plugin="$1"
    specified=$(grep "$plugin" ~/.tool-versions | awk '{$1=""; print $0}')
    installed=$(asdf list "$plugin" 2>&1)

    is_changed=
    for version in $specified; do
        match=$(echo "$installed" | grep "$version")
        [ -z "$match" ] && is_changed=1
    done

    [ "$is_changed" ]
}

for plugin in $(asdf plugin list); do
    if is_runtime_versions_changed "$plugin"; then
        log "Install runtime: $plugin"
        asdf install "$plugin"
    fi
done

# -------------------------------------------------------------------------
# for plugin in $(awk '{print $1}' ~/.tool-versions); do
#     if ! is_dir ~/.asdf/plugins/"$plugin"; then
#         asdf plugin add "$plugin"
#     fi
# done

# is_runtime_versions_changed() {
#     plugin="$1"
#     specified=$(grep "$plugin" ~/.tool-versions | awk '{$1=""; print $0}')
#     installed=$(asdf list "$plugin" 2>&1)

#     is_changed=
#     for version in $specified; do
#         match=$(echo "$installed" | grep "$version")
#         [ -z "$match" ] && is_changed=1
#     done

#     [ "$is_changed" ]
# }

# for plugin in $(asdf plugin list); do
#     if is_runtime_versions_changed "$plugin"; then
#         log "Install runtime: $plugin"
#         asdf install "$plugin"
#     fi
# done
