### locale ###
export LANG="en_US.UTF-8"

### XDG ###
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

### github.com ###
export GITHUB_USER_NAME="YousukeFujigaya"

### ghq ###
export GHQ_ROOT_PATH="$HOME/Repos"
export GHQ_GET_PATH="$GHQ_ROOT_PATH/github.com"

### homebrew ###
export HOMEBREW_NO_AUTO_UPDATE=1

### zsh ###
export ZDOTDIR="$XDG_CONFIG_HOME/zsh" # .zshrc を ~/.config/zsh から読み込むように設定
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

### fzf ###
export FZF_HOME="$XDG_DATA_HOME/fzf"

### z ###
export _Z_HOME="$XDG_DATA_HOME/z"
export _Z_DATA="$XDG_CACHE_HOME/z/z" # default ~/.z

### Starship ###
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

### Rust ###
export RUST_BACKTRACE=1
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

### Go ###
export GOPATH="$XDG_DATA_HOME/go"
export GO111MODULE="on"

### Deno ###
export DENO_INSTALL="$XDG_DATA_HOME/deno"

### Bundle ###
# export BUNDLE_USER_HOME="$XDG_CONFIG_HOME/bundle"
# export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
# export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle/plugin"
