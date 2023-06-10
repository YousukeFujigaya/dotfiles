# Setup fzf
# ---------
if [[ ! "$PATH" == *"$FZF_HOME"/bin* ]]; then
    PATH="${PATH:+${PATH}:}"$FZF_HOME"/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_HOME/shell/completion.zsh" 2>/dev/null

# Key bindings
# ------------
source "${XDG_CONFIG_HOME}/zsh/fzf-key-bindings.zsh"

#########################################################################
# settings
#########################################################################
export FZF_COMPLETION_TRIGGER='**' # default: '**'
export FZF_TMUX=1
# export FZF_DEFAULT_COMMAND='fd --hidden --color=always'
export FZF_DEFAULT_COMMAND="rg --files --hidden -l -g '!.git/*' -g '!node_modules/*'"

### --- FZF_TMUX_OPTS, FZF_DEFAULT_OPTS --- ###
if [[ -n ${TMUX-} ]]; then
    __FZF_CMD="fzf-tmux"
    __FZF_CMD_OPTS=(
        -p
        80%
    )

    export FZF_DEFAULT_OPTS="$(
        cat <<"EOF"
--preview '
  ( (type bat > /dev/null) &&
    bat --color=always --line-range :200 {} \
    || (cat {} | head -200) ) 2> /dev/null
'
EOF
    ) \
        --layout=reverse --border --ansi \
        --preview-window 'right,50%,nowrap' \
        --header 'Ctrl-\: Toggle Preview | Ctrl-P/N: Page Up/Down' \
        --bind 'Ctrl-\:toggle-preview' \
        --bind 'ctrl-p:preview-half-page-up,ctrl-n:preview-half-page-down'"

    export FZF_TMUX_OPTS="-p 90% -y45"
    # export FZF_TMUX_OPTS="-p 96% -y45"

else

    __FZF_CMD="fzf"
    __FZF_CMD_OPTS=()

    export FZF_DEFAULT_OPTS="$(
        cat <<"EOF"
    --preview '
          ( (type bat > /dev/null) &&
            bat --color=always --line-range :200 {} \
            || (cat {} | head -200) ) 2> /dev/null
        '
EOF
    ) \
                --height 100% --layout=reverse --border --ansi \
                --preview-window 'right,50%,nowrap' \
                --header 'Ctrl-\: Toggle Preview | Ctrl-P/N: Page Up/Down' \
                --bind 'ctrl-\:change-preview-window(hidden|)' \
                --bind 'ctrl-p:preview-half-page-up,ctrl-n:preview-half-page-down'"
fi

### --- alias --- ###
alias fzf="$(__fzfcmd) ${FZF_DEFAULT_OPTS-} --preview-window 'hidden'"

### --- options --- ###
export FZF_CTRL_R_OPTS=$(
    cat <<"EOF"
--preview '
  echo {} \
  | awk "{ sub(/^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+/, \"\"); gsub(/\\\\n/, \"\\n\"); print }" \
  | bat --color=always --language=sh --style=plain
'
--preview-window 'down,30%,hidden,wrap'
EOF
)

local find_ignore="find ./ -type d \( -name '.git' -o -name 'node_modules' \) -prune -o -type"

export FZF_CTRL_T_COMMAND=$(
    cat <<"EOF"
( (type fd > /dev/null) &&
  fd --type f \
    --strip-cwd-prefix \
    --hidden \
    --exclude '{.git,node_modules}/**' ) \
  || $find_ignore f -print 2> /dev/null
EOF
)
export FZF_CTRL_T_OPTS=$(
    cat <<"EOF"
--preview '
  ( (type bat > /dev/null) &&
    bat --color=always \
      --line-range :200 {} \
    || (cat {} | head -200) ) 2> /dev/null
'
--preview-window 'right,50%,nowrap'
EOF
)

export FZF_ALT_C_COMMAND=$(
    cat <<"EOF"
( (type fd > /dev/null) &&
  fd --type d \
    --strip-cwd-prefix \
    --hidden \
    --exclude '{.git,node_modules}/**' ) \
  || $find_ignore d -print 2> /dev/null
EOF
)
export FZF_ALT_C_OPTS="--preview 'exa --tree -L 3 {} | head -200'"

#########################################################################
# functions
#########################################################################
# カレントディレクトリ以下のディレクトリ検索・移動
find_cd() {
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
bindkey '^X' find_cd

# Tree表示
fzf-ghq() {
    local repo=("$(ghq list | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" \
        $(__fzfcmd) --prompt 'Repository> ' --preview "ghq list --full-path --exact {} | xargs exa \
        -h --long --icons --classify --git --no-permissions --no-user --no-filesize --git-ignore --sort modified --reverse --tree --level 4")")
    if [ -n "$repo" ]; then
        repo=$(ghq list --full-path --exact $repo)
        BUFFER="cd ${repo}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-ghq
bindkey '^[s' fzf-ghq

# かつていたことのあるディレクトリに移動する
fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" \
        $(__fzfcmd) --preview "echo {} | xargs exa \
        -h --long --icons --classify --git --no-permissions --no-user --no-filesize --git-ignore --sort modified --reverse --tree --level 4")
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}

zle -N fzf-z-search
bindkey '^z' fzf-z-search
