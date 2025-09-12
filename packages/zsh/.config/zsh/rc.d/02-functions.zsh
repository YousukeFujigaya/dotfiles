#########################################################################
# FUNCTIONS - Custom shell functions and widgets
#########################################################################
#
# This file contains custom functions and zsh widgets with keybindings.
# Functions are organized by category for better maintainability.
#
# KEYBINDINGS SUMMARY:
# - Ctrl+Z : fz() - Smart directory jump (z history)
# - Ctrl+B : find_cd() - Local directory search
# - Alt+S : fzf-ghq() - Repository navigation
# - Ctrl+F : tmux session create/switch
# - Ctrl+S : tmux session switch
# - Ctrl+X : tmux session kill
# - Ctrl+E : lf file manager
#
#########################################################################

### Basic utility functions ###

# History filtering function
zshaddhistory() {
  local line="${1%%$'\n'}"
  [[ ! "$line" =~ "^(cd|z|which|history|jj?|lazygit|la|ll|ls|rm|rmdir|trash)($| )" ]]
}

### zsh Widget Functions ###

# Clear screen with prompt update
clear-screen-and-update-prompt() {
    # ALMEL_STATUS=0
    # almel::precmd
    zle .clear-screen
}
zle -N clear-screen clear-screen-and-update-prompt

# History search widget using fzf
widget::history() {
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
    local selected=( "$(history -inr 1 | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} --scheme=history ${FZF_CTRL_R_OPTS-} \
        --prompt 'History> ' --exit-0 --query '$LBUFFER'" $(__fzfcmd) | cut -d' ' -f4- | sed 's/\\n/\n/g')" )
    if [ -n "$selected" ]; then
        BUFFER="$selected"
        CURSOR=$#BUFFER
    fi
    zle -R -c # refresh screen
}

### ghq Integration Widgets ###

# ghq repository listing with tmux session status
widget::ghq::source() {
    local session color icon green="\e[32m" blue="\e[34m" reset="\e[m" checked="󰄲" unchecked="󰄱"
    local sessions=($(tmux list-sessions -F "#S" 2>/dev/null))

    ghq list | sort | while read -r repo; do
        session="${repo//[:. ]/-}"
        color="$blue"
        icon="$unchecked"
        if (( ${+sessions[(r)$session]} )); then
            color="$green"
            icon="$checked"
        fi
        printf "$color$icon %s$reset\n" "$repo"
    done
}

# ghq repository selection with fzf
widget::ghq::select() {
    local root="$(ghq root)"
    widget::ghq::source | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} --exit-0 --prompt 'Repository> ' \
      --preview='fzf-preview-git ${(q)root}/{+2}' --preview-window='right:50%' " \
      $(__fzfcmd) | cut -d' ' -f2-
}

# Change directory to selected ghq repository
widget::ghq::dir() {
    local selected="$(widget::ghq::select)"
    if [ -z "$selected" ]; then
        return
    fi

    local repo_dir="$(ghq list --exact --full-path "$selected")"
    BUFFER="cd ${(q)repo_dir}"
    zle accept-line
    zle -R -c # refresh screen
}

# Create/switch tmux session for selected ghq repository
widget::ghq::session() {
    local selected="$(widget::ghq::select)"
    if [ -z "$selected" ]; then
        return
    fi

    local repo_dir="$(ghq list --exact --full-path "$selected")"
    local session_name="${selected//[:. ]/-}"

    if [ -z "$TMUX" ]; then
        BUFFER="tmux new-session -A -s ${(q)session_name} -c ${(q)repo_dir}"
        zle accept-line
    elif [ "$(tmux display-message -p "#S")" = "$session_name" ] && [ "$PWD" != "$repo_dir" ]; then
        BUFFER="cd ${(q)repo_dir}"
        zle accept-line
    else
        tmux new-session -d -s "$session_name" -c "$repo_dir" 2>/dev/null
        tmux switch-client -t "$session_name"
    fi
    zle -R -c # refresh screen
}


### Widget Registration ###
zle -N widget::history
zle -N widget::ghq::dir
zle -N widget::ghq::session

### Cursor shape functions for vi mode ###
# Change the cursor between 'Line' and 'Block' shape
zle-keymap-select() {
    case "${KEYMAP}" in
        main|viins)
            printf '\033[6 q' # line cursor
            ;;
        vicmd)
            printf '\033[2 q' # block cursor
            ;;
    esac
}

zle-line-init() {
    zle-keymap-select
}

zle-line-finish() {
    printf '\033[6 q' # line cursor
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

mkcd() { 
    # Create directory and change into it
    command mkdir -p -- "$@" && builtin cd "${@[-1]:a}" 
}

#########################################################################
# DIRECTORY NAVIGATION
#########################################################################

### fzf-enhanced navigation ###

fz() {
    # Smart directory jump using zoxide (Ctrl+Z)
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "zoxide not available"
        return 1
    fi
    
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
    local res=$(zoxide query --list --score | sort -nr | awk '{$1=""; print substr($0,2)}' | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" \
        $(__fzfcmd) --preview "echo {} | xargs eza \
        --color=always -h --long --icons --classify --git --no-permissions --no-user --no-filesize --git-ignore --sort modified --reverse --tree --level 4")
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}
zle -N fz
bindkey '^Z' fz

find_cd() {
    # Local directory search with fzf (Ctrl+B)
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
    local selected_dir=("$(fd . --type d | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} \
        --bind=ctrl-r:toggle-sort,ctrl-z:ignore \
        --exit-0 --query '$LBUFFER'" $(__fzfcmd))")
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle -R -c # refresh screen
}
zle -N find_cd
bindkey '^B' find_cd

fzf-ghq() {
    # Repository navigation with ghq (Alt+S)
    local repo=("$(ghq list | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" \
        $(__fzfcmd) --prompt 'Repository> ' --preview "ghq list --full-path --exact {} | xargs eza \
        --color=always -h --long --icons --classify --git --no-permissions --no-user --no-filesize --git-ignore --sort modified --reverse --tree --level 4")")
    if [ -n "$repo" ]; then
        repo=$(ghq list --full-path --exact $repo)
        BUFFER="cd ${repo}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-ghq
bindkey '^[s' fzf-ghq

### Git repository navigation ###

j() {
    # Fuzzy directory jump within git repository
    local root dir
    root="$($(git rev-parse --show-cdup 2>/dev/null):-.)"
    dir="$(fd --color=always --hidden --type=d . "$root" | fzf --select-1 --query="$*" --preview='fzf-preview-directory {}')"
    if [ -n "$dir" ]; then
        builtin cd "$dir"
        echo "$PWD"
    fi
}

jj() {
    # Jump to git repository root
    local root
    root="$(git rev-parse --show-toplevel)" || return 1
    builtin cd "$root"
}

#########################################################################
# BUILD TOOLS - CMake utilities
#########################################################################
cmakeb() {
    # Build project using cmake
    build_dir=${1:-$(git rev-parse --show-toplevel)/build}
    shift || true
    cmake --build "$build_dir" -j"$(($(nproc) + 1))" "$@"
}

cmaket() {
    # Run ctest in specified directory
    test_dir=${1:-$(git rev-parse --show-toplevel)/build}
    shift || true
    ctest --verbose --test-dir "$test_dir" "$@"
}

#########################################################################
# TMUX INTEGRATION - Session management
#########################################################################

tmux_sessionizer_popup() {
    # Create or switch tmux session with popup (Ctrl+F)
    if [ -n "$TMUX" ]; then
        tmux display-popup -w 90% -h 90% -E "~/.local/bin/tmux-sessionizer-popup"
    else
        ~/.local/bin/tmux-sessionizer-popup
    fi
    zle reset-prompt
}
zle -N tmux_sessionizer_popup
bindkey '^F' tmux_sessionizer_popup

tmux_switch_session() {
    # Switch between tmux sessions (Ctrl+S)
    if [ -n "$TMUX" ]; then
        tmux display-popup -w 90% -h 90% -E "~/.local/bin/tmux-switch-session"
    else
        echo "Not in tmux session"
    fi
    zle reset-prompt
}
zle -N tmux_switch_session
bindkey '^S' tmux_switch_session

tmux_kill_session() {
    # Kill tmux session (Ctrl+X)
    if [ -n "$TMUX" ]; then
        tmux display-popup -w 90% -h 90% -E "~/.local/bin/tmux-kill-session"
    else
        echo "Not in tmux session"
    fi
    zle reset-prompt
}
zle -N tmux_kill_session
bindkey '^X' tmux_kill_session

#########################################################################
# FILE MANAGEMENT
#########################################################################

### lf file manager integration ###

lf_popup() {
    # Launch lf file manager in tmux popup (Ctrl+E)
    if [ -n "$TMUX" ]; then
        tmux display-popup -w 90% -h 90% -E "~/.local/bin/lf-tmux"
    else
        lf
    fi
    zle reset-prompt
}
zle -N lf_popup
bindkey '^E' lf_popup

lf() {
    # lf wrapper that changes shell directory on exit
    tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

### Editor integration ###

e() {
    # Enhanced editor function with fzf file selection
    if [ $# -eq 0 ]; then
        local selected="$(fd --hidden --color=always --type=f  | fzf --exit-0 --multi --preview="fzf-preview-file {}" --preview-window="right:60%")"
        if [ -n "$selected" ]; then
            if [[ "$EDITOR" == "nvim" ]]; then
                VIMINIT= "$EDITOR" -- ${(f)selected}
            else
                "$EDITOR" -- ${(f)selected}
            fi
        fi
    else
        if [[ "$EDITOR" == "nvim" ]]; then
            VIMINIT= "$EDITOR" "$@"
        else
            "$EDITOR" "$@"
        fi
    fi
}

#########################################################################
# DOCKER UTILITIES (commented out)
#########################################################################
# These Docker helper functions are commented out but available if needed.
# Uncomment and modify as required for your Docker workflow.
# docker() {
#     if [ "$#" -eq 0 ] || [ "$1" = "compose" ] || ! command -v "docker-$1" >/dev/null; then
#         command docker "${@:1}"
#     else
#         "docker-$1" "${@:2}"
#     fi
# }

# docker-clean() {
#     command docker ps -aqf status=exited | xargs -r docker rm --
# }
# docker-cleani() {
#     command docker images -qf dangling=true | xargs -r docker rmi --
# }
# docker-rm() {
#     if [ "$#" -eq 0 ]; then
#         command docker ps -a | fzf --exit-0 --multi --header-lines=1 | awk '{ print $1 }' | xargs -r docker rm --
#     else
#         command docker rm "$@"
#     fi
# }
# docker-rmi() {
#     if [ "$#" -eq 0 ]; then
#         command docker images | fzf --exit-0 --multi --header-lines=1 | awk '{ print $3 }' | xargs -r docker rmi --
#     else
#         command docker rmi "$@"
#     fi
# }
