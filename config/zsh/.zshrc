# =============================================================================
# History
# =============================================================================

HISTFILE=$HOME/.zsh_history
HISTSIZE=3000
SAVEHIST=3000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# =============================================================================
# Completion
# =============================================================================

autoload -Uz compinit
compinit

zstyle ":completion:*" menu select=2
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}
zstyle ":completion:*" group-name ""
zstyle ":completion:*" matcher-list 'm:{a-z}={A-Z}'

# =============================================================================
# Keybinds
# =============================================================================

bindkey '^H' backward-kill-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char

# =============================================================================
# Extra Features
# =============================================================================

# Starship prompter
eval "$(starship init zsh)"

# Check for autosuggestions
for plugin in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f "$plugin" ]] && source "$plugin" && break
done

# Check for syntax highlighting
for plugin in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -f "$plugin" ]] && source "$plugin" && break
done

export FZF_DEFAULT_OPTS='--height 16 --layout=reverse --border --preview "bat --color=always --theme=gruvbox-dark \
  --style=numbers --line-range=:500 {}"'
source <(fzf --zsh)

# =============================================================================
# Alias'
# =============================================================================

if ! command -v hx &>/dev/null; then
  alias hx='helix'
fi

alias ls='ls --color=tty --group-directories-first'
alias lsa='ls -Al --color=tty --group-directories-first'
alias lg='lazygit'
alias ga='git add'
alias gc='git commit'
alias gs='git status'
alias gd='git diff'
alias gr='git restore --staged'

# =============================================================================
# COLORIZE MANPAGES
# =============================================================================

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'
# export GROFF_NO_SGR=1

unset GROFF_NO_SGR
export MANROFFOPT='-c'

# =============================================================================
# Environment Variables
# =============================================================================

export EDITOR="hx"
export VISUAL="hx"
export PAGER='less'
export MANPAGER="less -R"
export LESS='-R'
