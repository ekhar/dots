# Keep the preamble silent for Powerlevel10k instant prompt.
export DIRENV_LOG_FORMAT=
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Let each tmux pane reconstruct direnv state from its own working directory.
if [[ -n "$TMUX" ]]; then
  unset DIRENV_DIFF DIRENV_DIR DIRENV_FILE DIRENV_WATCHES
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

case "$(uname -s)" in
  Darwin) DOTFILES_OS=macos ;;
  Linux) DOTFILES_OS=linux ;;
  *) DOTFILES_OS=unknown ;;
esac
export DOTFILES_OS

# History shared across interactive shells.
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Paths. fnm owns the active Node and Pi installation paths.
typeset -U path PATH
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
if [[ "$DOTFILES_OS" == macos ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
path=(
  "$HOME/dots/scripts"
  "$HOME/.opencode/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.pulumi/bin"
  "$GOPATH/bin"
  "$PNPM_HOME"
  $path
)

export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
export VISUAL=nvim

[[ -f /etc/rancher/k3s/k3s.yaml ]] && export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
[[ -d /opt/devkitpro ]] && export DEVKITPRO=/opt/devkitpro
[[ -d /opt/devkitpro/devkitARM ]] && export DEVKITARM=/opt/devkitpro/devkitARM
[[ -d /opt/devkitpro/devkitPPC ]] && export DEVKITPPC=/opt/devkitpro/devkitPPC

# Oh My Zsh and prompt.
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  zstyle ':omz:update' mode disabled
  ZSH_THEME="powerlevel10k/powerlevel10k"
  plugins=(git vi-mode)
  source "$ZSH/oh-my-zsh.sh"
fi
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Interactive tool integrations.
if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null 2>&1; then
  if fzf_shell_init=$(fzf --zsh 2>/dev/null); then
    eval "$fzf_shell_init"
  else
    [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"

if [[ "$DOTFILES_OS" == macos ]]; then
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
  [[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh" ]] && \
    source "$HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh"
else
  for plugin_file in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
    if [[ -r "$plugin_file" ]]; then
      source "$plugin_file"
      break
    fi
  done
  for plugin_file in \
    /usr/share/zsh/plugins/forgit/forgit.plugin.zsh \
    "$ZSH/custom/plugins/forgit/forgit.plugin.zsh"; do
    if [[ -r "$plugin_file" ]]; then
      source "$plugin_file"
      break
    fi
  done
fi
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if [[ "$DOTFILES_OS" == macos ]]; then
  _clip_cmd=pbcopy
elif command -v wl-copy >/dev/null 2>&1; then
  _clip_cmd=wl-copy
else
  _clip_cmd='xclip -selection clipboard'
fi
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | $_clip_cmd)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
else
  export FZF_CTRL_T_OPTS="--preview 'sed -n \"1,120p\" {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

# Safe defaults. Permission-bypassing agent modes are explicit opt-ins.
alias python=python3
alias ls=eza
alias ll='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias nano=nvim
alias mux=tmuxinator
alias codex-yolo='IS_SANDBOX=1 codex --yolo'
alias claude-yolo='IS_SANDBOX=1 claude --dangerously-skip-permissions'
alias doctor=dots-doctor
alias de='direnv edit'
alias da='direnv allow'
alias dr='direnv reload'
alias ds='direnv status'
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'
[[ -f /etc/rancher/k3s/k3s.yaml ]] && alias k9s='k9s --kubeconfig /etc/rancher/k3s/k3s.yaml'

openclaw-ssh() {
  (cd /tmp/openclaw-railway && railway ssh -s openclaw-gateway)
}

_project_dirs() {
  if command -v fd >/dev/null 2>&1; then
    fd --type d --max-depth 2 . "$HOME/code" 2>/dev/null
  else
    find "$HOME/code" -maxdepth 2 -type d 2>/dev/null
  fi
}

proj() {
  local dir
  dir=$(_project_dirs | fzf --preview 'eza --tree --level=1 --color=always {}')
  [[ -n "$dir" ]] && cd "$dir"
}

tproj() {
  local dir session
  dir=$(_project_dirs | fzf --preview 'eza --tree --level=1 --color=always {}')
  [[ -z "$dir" ]] && return 0

  session=${dir:t}
  session=${session//./-}
  session=${session// /-}

  if tmux has-session -t "$session" 2>/dev/null; then
    tmux switch-client -t "$session" 2>/dev/null || tmux attach-session -t "$session"
  else
    tmux new-session -d -s "$session" -c "$dir"
    tmux switch-client -t "$session" 2>/dev/null || tmux attach-session -t "$session"
  fi
}

gbf() {
  local branch
  branch=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes/origin |
    sed 's#^origin/##' | awk '!seen[$0]++' |
    fzf --preview 'git log --oneline --graph --color=always {} -- | head -20')
  [[ -n "$branch" ]] && git switch "$branch"
}

gsf() {
  git status --short | fzf --preview 'git diff --color=always -- {2}' --multi | awk '{print $2}'
}

export MARKPATH="$HOME/.marks"
mark() {
  [[ -z "$1" ]] && { echo 'usage: mark <name>' >&2; return 2; }
  mkdir -p "$MARKPATH"
  ln -s "$(pwd)" "$MARKPATH/$1"
}
unmark() { rm -i "$MARKPATH/$1"; }
marks() { eza -l "$MARKPATH"; }
jump() { cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"; }
alias j=jump

ff() {
  local file
  if command -v bat >/dev/null 2>&1; then
    file=$(fzf --preview 'bat --color=always --line-range :100 {}')
  else
    file=$(fzf --preview 'sed -n "1,120p" {}')
  fi
  [[ -n "$file" ]] && "$EDITOR" "$file"
}

extract() {
  [[ -z "$1" ]] && { echo 'usage: extract <archive>' >&2; return 2; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *.rar) unrar x "$1" ;;
    *) echo "'$1' cannot be extracted" >&2; return 1 ;;
  esac
}

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -r "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Syntax highlighting must be sourced last.
if [[ "$DOTFILES_OS" == macos ]]; then
  [[ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  for plugin_file in \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
    if [[ -r "$plugin_file" ]]; then
      source "$plugin_file"
      break
    fi
  done
fi
