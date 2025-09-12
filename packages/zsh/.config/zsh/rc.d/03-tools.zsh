### External Tools Configuration ###

### Interactive shell environment variables ###
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

### fzf ###
[ -f "$XDG_CONFIG_HOME"/fzf/fzf.zsh ] && source "$XDG_CONFIG_HOME"/fzf/fzf.zsh

### tmux-sessionizer ###
export TMUX_SESSIONIZER_HOME="$XDG_DATA_HOME/tmux-sessionizer"
if [ ! -d "$GHQ_ROOT_PATH/github.com/ThePrimeagen/tmux-sessionizer" ]; then
    ghq get ThePrimeagen/tmux-sessionizer
    if [ ! -d "$TMUX_SESSIONIZER_HOME" ]; then
        echo "Linking tmux-sessionizer Repository to $XDG_DATA_HOME ..."
        ln -sfnv "$GHQ_ROOT_PATH/github.com/ThePrimeagen/tmux-sessionizer" "$TMUX_SESSIONIZER_HOME"
    fi
fi


### direnv ###
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

### bat ###
export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat"
export MANPAGER="sh -c 'col -bx | bat --color=always --language=man --plain'"

### ripgrep ###
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"


### ls-colors ###
export LS_COLORS="di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32"

### less ###
export LESSHISTFILE='-'

### GPG ###
export GPG_TTY="$(tty)"

### Editor ###
export EDITOR="vi"
command -v vim >/dev/null && EDITOR="vim"
command -v nvim >/dev/null && EDITOR="nvim"
export GIT_EDITOR="$EDITOR"

### Docker config ###
# export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"