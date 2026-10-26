# ZSH Configuration

HISTFILE=$HOME/.zsh_history
HISTSIZE=3000
SAVEHIST=3000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

autoload -Uz compinit
compinit

zstyle ":completion:*" menu select=2
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}
zstyle ":completion:*" group-name ""
zstyle ":completion:*" matcher-list 'm:{a-z}={A-Z}'

bindkey '^H' backward-kill-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char

eval "$(starship init zsh)"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export MANPAGER="bat -plman"

export FZF_DEFAULT_OPTS='--height 16 --layout=reverse --border --preview "bat --color=always --theme=gruvbox-dark --style=numbers --line-range=:500 {}"'
source <(fzf --zsh)

alias hx="helix"
export EDITOR="helix"

alias ls='ls --color=tty --group-directories-first'
alias lsa='ls -Al --color=tty --group-directories-first'

alias lg='lazygit'

alias ga='git add'
alias gc='git commit'
alias gs='git status'
alias gd='git diff'
alias gr='git restore --staged'

. "$HOME/.local/bin/env"
