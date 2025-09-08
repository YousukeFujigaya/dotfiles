### zinit ###
# ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# ZINIT[ZCOMPDUMP_PATH]="$XDG_STATE_HOME/zcompdump"
# [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
# [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# source "${ZINIT_HOME}/zinit.zsh"

typeset -gAH ZINIT
ZINIT[HOME_DIR]="$XDG_DATA_HOME/zinit"
ZINIT[ZCOMPDUMP_PATH]="$XDG_STATE_HOME/zsh/zcompdump"
source "${ZINIT[HOME_DIR]}/bin/zinit.zsh"

### paths ###
typeset -U path
typeset -U fpath

path=(
  "/opt/homebrew/bin"(N-/)
  "/opt/homebrew/sbin"(N-/)
  "$HOME/.local/bin"(N-/)
  "$CARGO_HOME/bin"(N-/)
  "$GOPATH/bin"(N-/)
  "$DENO_INSTALL/bin"(N-/)
  "$GEM_HOME/bin"(N-/)
  "$XDG_CONFIG_HOME/scripts/bin"(N-/)
  "$path[@]"
  "/Library/Apple/usr/bin"(N-/)
)

fpath=(
  "$XDG_DATA_HOME/zsh/completions"(N-/)
  "$fpath[@]"
)

### history ###
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=12000
export SAVEHIST=1000000
export EDITOR="vim"
export TERMINAL="alacritty"
# export BROWSER="brave"

### options ###
setopt NO_BEEP
setopt IGNOREEOF
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt GLOBDOTS
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE # NOTE: 行頭にspaceを入れたコマンドをhistoryに履歴を残さないようにできる
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt SHARE_HISTORY
# setopt NO_SHARE_HISTORY
setopt MAGIC_EQUAL_SUBST
setopt PRINT_EIGHT_BIT
setopt NO_FLOW_CONTROL

zshaddhistory() {
  local line="${1%%$'\n'}"
  [[ ! "$line" =~ "^(cd|z|which|history|jj?|lazygit|la|ll|ls|rm|rmdir|trash)($| )" ]]
}

### Customize Prompt ###
if command -v brew starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    zinit ice as"command" from"gh-r" \
        atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
        atpull"%atclone" src"init.zsh"
    zinit light starship/starship
fi

### runtime tool manager ###
if command -v rtx >/dev/null 2>&1; then
    eval "$(rtx activate zsh)"
fi

### key bindings ###
clear-screen-and-update-prompt() {
    # ALMEL_STATUS=0
    # almel::precmd
    zle .clear-screen
}
zle -N clear-screen clear-screen-and-update-prompt

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

widget::ghq::select() {
    local root="$(ghq root)"
    widget::ghq::source | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} --exit-0 --prompt 'Repository> ' \
      --preview='fzf-preview-git ${(q)root}/{+2}' --preview-window='right:50%' " \
      $(__fzfcmd) | cut -d' ' -f2-
    # widget::ghq::source | fzf --exit-0 --preview="fzf-preview-git ${(q)root}/{+2}" --preview-window="right:60%" | cut -d' ' -f2-
}

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

forward-kill-word() {
  zle vi-forward-word
  zle vi-backward-kill-word
}

zle -N widget::history
zle -N widget::ghq::dir
zle -N widget::ghq::session
zle -N forward-kill-word

bindkey -v
bindkey "^R" widget::history            # C-r
bindkey "^G" widget::ghq::session       # C-g
bindkey "^[g" widget::ghq::dir          # Alt-g
bindkey "^A" beginning-of-line          # C-a
bindkey "^E" end-of-line                # C-e
bindkey "^K" kill-line                  # C-k
bindkey "^Q" push-line-or-edit          # C-q
bindkey "^W" vi-backward-kill-word      # C-w
bindkey "^X^W" forward-kill-word        # C-x C-w
bindkey "^?" backward-delete-char       # backspace
bindkey "^[[3~" delete-char             # delete
bindkey "^[[1;3D" backward-word         # Alt + arrow-left
bindkey "^[[1;3C" forward-word          # Alt + arrow-right
bindkey "^[^?" vi-backward-kill-word    # Alt + backspace
bindkey "^[[1;33~" kill-word            # Alt + delete
bindkey -M vicmd "^A" beginning-of-line # vi: C-a
bindkey -M vicmd "^E" end-of-line       # vi: C-e

# Change the cursor between 'Line' and 'Block' shape
function zle-keymap-select zle-line-init zle-line-finish {
    case "${KEYMAP}" in
        main|viins)
            printf '\033[6 q' # line cursor
            ;;
        vicmd)
            printf '\033[2 q' # block cursor
            ;;
    esac
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

### plugins ###
zinit light @'zsh-users/zsh-autosuggestions' # MEMO: ここでloadしないとshell起動時に機能しなかった。

zinit wait lucid null silent nocd for \
  atinit'source "$ZDOTDIR/.zshrc.lazy"' \
  @'zdharma-continuum/null'
