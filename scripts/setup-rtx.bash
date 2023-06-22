#!/usr/bin/env bash
set -e
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"
source "$(dirname "$0")/utils.sh"

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

### Install plugins
for plugin in $(awk '{print $1}' ~/.tool-versions); do
    if ! is_dir "$XDG_DATA_HOME/rtx/plugins/$plugin"; then
        log "Installing rtx plugins: $plugin ..."
        rtx plugin add "$plugin"
    fi
done

is_runtime_versions_changed() {
    plugin="$1"
    specified=$(grep "$plugin" ~/.tool-versions | awk '{$1=""; print $0}')
    installed=$(rtx list "$plugin" 2>&1)

    is_changed=
    for version in $specified; do
        match=$(echo "$installed" | grep "$version")
        [ -z "$match" ] && is_changed=1
    done

    [ "$is_changed" ]
}

for plugin in $(rtx plugin list); do
    if is_runtime_versions_changed "$plugin"; then
        log "Install runtime: $plugin"
        rtx install "$plugin"
    fi
done

### Updating
[[ "$skip_update" == 1 ]] && exit

log "Updating rtx plugins..."
rtx plugins update --all
