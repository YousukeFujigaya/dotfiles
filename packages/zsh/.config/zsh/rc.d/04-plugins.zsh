# ==========================================
#  Zinit Plugins Configuration
# ==========================================

# ==========================================
#  Shell Enhancement Plugins
# ==========================================

# zsh-autosuggestions - Command autosuggestions based on history
zinit wait lucid light-mode for \
    @'zsh-users/zsh-autosuggestions'

# zsh-history-substring-search - Advanced history search with arrow keys
__zsh_history_substring_search_atload() {
    bindkey "${terminfo[kcuu1]}" history-substring-search-up   # arrow-up
    bindkey "${terminfo[kcud1]}" history-substring-search-down # arrow-down
    bindkey "^[[A" history-substring-search-up   # arrow-up
    bindkey "^[[B" history-substring-search-down # arrow-down
}
zinit wait lucid light-mode for \
    atload'__zsh_history_substring_search_atload' \
    @'zsh-users/zsh-history-substring-search'

# zsh-autopair - Automatically pair brackets and quotes
zinit wait'1' lucid light-mode for \
    @'hlissner/zsh-autopair'

# Core zsh enhancement plugins
zinit wait lucid blockf light-mode for \
    atload'async_init' @'mafredri/zsh-async' \
    @'zsh-users/zsh-completions' \
    @'zdharma-continuum/fast-syntax-highlighting'

# ==========================================
#  Package Management Strategy
# ==========================================
# 
# Homebrew: System tools, heavy dependencies, frequent updates
# - starship, ripgrep, gh, eza, bat, fd, delta, navi
# - Completions: /opt/homebrew/share/zsh/site-functions/
#
# zinit: Lightweight utilities, shell-specific plugins
# - mmv, tealdeer, zoxide
# - zsh-autosuggestions, fast-syntax-highlighting, etc.
#
# ==========================================
#  Lightweight Utilities (zinit-managed)
# ==========================================

# starship - Cross-shell prompt (currently managed by Homebrew)
# Uncomment below to switch from Homebrew to zinit management
# zinit ice as"command" from"gh-r" \
#     atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#     atpull"%atclone" src"init.zsh"
# zinit light starship/starship

# mmv - File mover utility
zinit wait lucid light-mode as'program' from'gh-r' for \
    pick'mmv*/mmv' @'itchyny/mmv'

# GitHub CLI completion is available via Homebrew at /opt/homebrew/share/zsh/site-functions/_gh

# eza - Modern ls replacement (installed via Homebrew)
# Aliases are defined in 01-aliases.zsh
# Completion available at /opt/homebrew/share/zsh/site-functions/_eza

# ==========================================
#  Productivity & Navigation Tools  
# ==========================================

# navi - Interactive cheat sheet for terminal commands (Ctrl+N to search)
# navi installed via Homebrew, configuration and keybindings below
__navi_search() {
    LBUFFER="$(navi --print --path '$XDG_CONFIG_HOME/navi/cheats' --query="$LBUFFER")"
    zle reset-prompt
}
__setup_navi() {
    if command -v navi >/dev/null; then
        export NAVI_CONFIG="$XDG_CONFIG_HOME/navi/config.yaml"
        alias mynavi="navi --path '$XDG_CONFIG_HOME/navi/cheats'"

        zle -N __navi_search
        bindkey '^N' __navi_search
    fi
}
__setup_navi

# forgit - Interactive git interface with fzf
__forgit_atload() {
    export FORGIT_INSTALL_DIR="$PWD"
    export FORGIT_NO_ALIASES=1
}
zinit wait lucid light-mode as'program' for \
    atload'__forgit_atload' \
    pick'bin/git-forgit' \
    @'wfxr/forgit'

# zoxide - Smart directory jumping based on frequency (XDG compliant)
__zoxide_atload() {
    # XDG Base Directory compliance
    export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"   # Database location (persistent data)
    export _ZO_EXCLUDE_DIRS="$HOME"               # Exclude home directory from tracking
    export _ZO_RESOLVE_SYMLINKS=1                 # Resolve symlinks for consistency
    eval "$(zoxide init zsh)"
}
zinit wait lucid light-mode as'program' from'gh-r' for \
    pick'zoxide*/zoxide' \
    atclone'./zoxide*/zoxide init zsh >init.zsh' atpull'%atclone' \
    atload'__zoxide_atload' \
    @'ajeetdsouza/zoxide'

# ==========================================
#  Documentation & Help Tools
# ==========================================

# tealdeer - Fast tldr client for command documentation (alias: tldr)
__tealdeer_atclone() {
    curl -sSL 'https://raw.githubusercontent.com/dbrgn/tealdeer/main/completion/zsh_tealdeer' -o _tealdeer
}
__tealdeer_atload() {
    export TEALDEER_CONFIG_DIR="$XDG_CONFIG_HOME/tealdeer"
}
zinit wait lucid light-mode as'program' from'gh-r' for \
    mv'tealdeer* -> tldr' \
    atclone'__tealdeer_atclone' atpull'%atclone' \
    atload'__tealdeer_atload' \
    @'dbrgn/tealdeer'

# ==========================================
#  Modern CLI Replacements
# ==========================================

# fd completion is available via Homebrew at /opt/homebrew/share/zsh/site-functions/_fd

# bat completion is available via Homebrew at /opt/homebrew/share/zsh/site-functions/_bat

# ==========================================
#  Commented Out / Optional Plugins
# ==========================================

# yq - YAML processor (alternative to jq for YAML)
# zinit wait lucid light-mode as'program' from'gh-r' for \
#     mv'yq* -> yq' \
#     atclone'./yq shell-completion zsh >_yq' atpull'%atclone' \
#     @'mikefarah/yq'

# hgrep - Human-readable grep with highlighting
# __hgrep_atload() {
#     alias hgrep="hgrep --hidden --glob='!.git/'"
# }
# zinit wait lucid light-mode as'program' from'gh-r' for \
#     pick'hgrep*/hgrep' \
#     atload'__hgrep_atload' \
#     @'rhysd/hgrep'

# zeno.zsh - Deno-powered snippet expansion (requires deno)
# if command -v deno >/dev/null 2>&1; then
#     export ZENO_HOME="$XDG_CONFIG_HOME/zeno"
#     export ZENO_ENABLE_SOCK=1
#     export ZENO_GIT_CAT="bat --color=always"
#     export ZENO_GIT_TREE="exa --tree"
#     __zeno_atload() {
#         bindkey ' '  zeno-auto-snippet
#         bindkey '^M' zeno-auto-snippet-and-accept-line
#         bindkey '^P' zeno-completion
#     }
#     zinit wait lucid light-mode for \
#         atload'__zeno_atload' \
#         @'yuki-yano/zeno.zsh'
# fi

# emojify - Add emoji to your terminal output
# zinit wait lucid light-mode as'program' for \
#     atclone'rm -f *.{py,bats}' atpull'%atclone' \
#     @'mrowa44/emojify'

# zsh-replace-multiple-dots - Convert ... to ../.. automatically
# __replace_multiple_dots_atload() {
#     replace_multiple_dots_exclude_go() {
#         if [[ "$LBUFFER" =~ '^go ' ]]; then
#             zle self-insert
#         else
#             zle .replace_multiple_dots
#         fi
#     }
#     zle -N .replace_multiple_dots replace_multiple_dots
#     zle -N replace_multiple_dots replace_multiple_dots_exclude_go
# }
# zinit wait lucid light-mode for \
#     atload'__replace_multiple_dots_atload' \
#     @'momo-lab/zsh-replace-multiple-dots'