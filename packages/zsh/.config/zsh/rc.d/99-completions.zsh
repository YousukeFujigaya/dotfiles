### Completion Settings ###

### completion styles ###
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' cache-path $XDG_STATE_HOME/zsh/zcompdump

### Utility functions ###
autoload -Uz zmv                    # Multi-move utility
autoload -Uz zargs                  # Extended xargs

### Completion functions ###
autoload -Uz _git           # Enable git completion
autoload -Uz _npm           # Enable npm completion  
autoload -Uz _curl          # Enable curl completion
autoload -Uz _ssh           # Enable ssh completion
autoload -Uz _make          # Enable make completion (Makefile targets)
autoload -Uz _tar           # Enable tar completion
autoload -Uz _rsync         # Enable rsync completion
autoload -Uz _grep          # Enable grep completion
autoload -Uz _find          # Enable find completion
command -v brew >/dev/null && autoload -Uz _brew  # Enable brew completion if available

### Initialize completion system ###
autoload -Uz compinit && compinit -C -u
autoload compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
zpcompinit