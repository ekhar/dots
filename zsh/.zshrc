# Platform detection (must be early)
case "$(uname -s)" in
    Darwin) DOTFILES_OS="macos" ;;
    Linux)  DOTFILES_OS="linux" ;;
esac
export DOTFILES_OS

# pfetch must be BEFORE instant prompt (it outputs to console)
command -v pfetch &>/dev/null && pfetch

# Powerlevel10k instant prompt (must be after any console output)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew setup (macOS - must be early for brew --prefix to work)
if [[ "$DOTFILES_OS" == "macos" ]]; then
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# PATH configuration
typeset -U PATH
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"

# Platform-specific PNPM path
if [[ "$DOTFILES_OS" == "macos" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi

path=(
  "$HOME/.local/bin"
  "$HOME/.config/emacs/bin"
  "$HOME/.cargo/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.pulumi/bin"
  "$GOPATH/bin"
  "$PNPM_HOME"
  $path
)

# Environment variables
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export TMUX_CONF="$HOME/.config/tmux/tmux.conf"
export DEVKITPRO="/opt/devkitpro"
export DEVKITARM="/opt/devkitpro/devkitARM"
export DEVKITPPC="/opt/devkitpro/devkitPPC"
unset DOCKER_HOST

# Kubeconfig (only if k3s exists)
[[ -f /etc/rancher/k3s/k3s.yaml ]] && export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

# Oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git vi-mode)
source $ZSH/oh-my-zsh.sh

# Tool initializations
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd)"

# Autosuggestions and plugins (platform-specific paths)
if [[ "$DOTFILES_OS" == "macos" ]]; then
    # macOS: Homebrew-installed plugins
    [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
        source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$(brew --prefix)/share/forgit/forgit.plugin.zsh" ]] && \
        source "$(brew --prefix)/share/forgit/forgit.plugin.zsh"
else
    # Linux: System or oh-my-zsh custom plugins
    if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    elif [[ -f $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
    # forgit on Linux
    if [[ -f /usr/share/zsh/plugins/forgit/forgit.plugin.zsh ]]; then
        source /usr/share/zsh/plugins/forgit/forgit.plugin.zsh
    elif [[ -f $ZSH/custom/plugins/forgit/forgit.plugin.zsh ]]; then
        source $ZSH/custom/plugins/forgit/forgit.plugin.zsh
    fi
fi
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# FZF configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Platform-specific clipboard command for FZF
if [[ "$DOTFILES_OS" == "macos" ]]; then
    _clip_cmd="pbcopy"
else
    _clip_cmd="xclip -selection clipboard"
fi

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | $_clip_cmd)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Aliases
alias ls='eza'
alias ll='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias tmux='tmux -f $TMUX_CONF'
alias nano='nvim'

# Platform-specific aliases
if [[ "$DOTFILES_OS" == "macos" ]]; then
    alias claude="$HOME/.claude/local/claude"
else
    # Linux: pbcopy/pbpaste aliases
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

# k9s alias (only if kubeconfig exists)
[[ -f /etc/rancher/k3s/k3s.yaml ]] && alias k9s='k9s --kubeconfig /etc/rancher/k3s/k3s.yaml'

# Tmuxinator aliases
alias mux="tmuxinator"
alias sal="tmuxinator start saliently"
alias hlab="tmuxinator start homelab"
alias dev="tmuxinator start coding"

# Source external files
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ -f ~/.env ]] && source ~/.env
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Git/Dev Workflow
gbf() {
  git branch -a --sort=-committerdate |
    fzf --preview 'git log --oneline --graph --color=always {1} -- | head -20' |
    sed 's/remotes\/origin\///' | xargs git checkout
}

gsf() {
  git status -s | fzf --preview 'git diff --color=always {2}' --multi | awk '{print $2}'
}

alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'

# Navigation
proj() {
  local dir
  dir=$(find "$HOME/code" -maxdepth 2 -type d 2>/dev/null | fzf --preview 'eza --tree --level=1 --color=always {}')
  [[ -n "$dir" ]] && cd "$dir"
}

export MARKPATH="$HOME/.marks"
mark() { mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"; }
unmark() { rm -i "$MARKPATH/$1"; }
marks() { eza -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | column -t; }
jump() { cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"; }
alias j='jump'

ff() {
  local file
  file=$(fzf --preview 'bat --color=always --line-range :100 {}')
  [[ -n "$file" ]] && $EDITOR "$file"
}

# Quality of Life (auto-ls after cd, skips during init)
chpwd() {
  [[ -v _zsh_init_done ]] && eza --icons=always
}

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

extract() {
  case $1 in
    *.tar.bz2) tar xjf $1 ;;
    *.tar.gz)  tar xzf $1 ;;
    *.tar.xz)  tar xJf $1 ;;
    *.bz2)     bunzip2 $1 ;;
    *.gz)      gunzip $1 ;;
    *.tar)     tar xf $1 ;;
    *.tbz2)    tar xjf $1 ;;
    *.tgz)     tar xzf $1 ;;
    *.zip)     unzip $1 ;;
    *.7z)      7z x $1 ;;
    *.rar)     unrar x $1 ;;
    *)         echo "'$1' cannot be extracted" ;;
  esac
}

calc() { python3 -c "print($*)" }

_zsh_init_done=1

# Syntax highlighting (MUST be last)
if [[ "$DOTFILES_OS" == "macos" ]]; then
    [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
    if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    elif [[ -f $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi
