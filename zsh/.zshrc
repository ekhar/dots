# Interactive zsh, started by Ghostty and tmux. The account's login shell is bash,
# which agents run, so SHELL is corrected for programs started from here.
export SHELL=/bin/zsh

# Let each tmux pane reconstruct direnv state from its own working directory.
[[ -n "$TMUX" ]] && unset DIRENV_DIFF DIRENV_DIR DIRENV_FILE DIRENV_WATCHES
export DIRENV_LOG_FORMAT=

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS COMPLETE_IN_WORD ALWAYS_TO_END

# Paths. Missing directories are dropped. fnm owns Node.
export EDITOR=nvim VISUAL=nvim
export GOPATH="$HOME/go" BUN_INSTALL="$HOME/.bun"
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
typeset -U path PATH
_dirs=("$HOME/dots/scripts" "$HOME/.local/bin" "$HOME/.opencode/bin" "$HOME/.t3/bin" "$HOME/.cargo/bin"
  "$BUN_INSTALL/bin" "$HOME/.pulumi/bin" "$GOPATH/bin" "$PNPM_HOME")
path=(${^_dirs}(N-/) $path)
unset _dirs

# Completion, with the cache rebuilt at most once a day.
zmodload zsh/complist
autoload -Uz compinit
() {
  setopt local_options extended_glob
  mkdir -p "${1:h}"
  if [[ -n $1(#qN.mh-24) ]]; then compinit -C -d "$1"; else compinit -d "$1"; fi
} "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Vi keys, keeping the emacs-style insert-mode keys and prefix history search.
bindkey -v
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey -M viins \
  '^?' backward-delete-char '^H' backward-delete-char '^W' backward-kill-word '^[^?' backward-kill-word \
  '^A' beginning-of-line '^E' end-of-line '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char \
  '^[[1;5C' forward-word '^[[1;5D' backward-word \
  '^[[A' up-line-or-beginning-search '^[OA' up-line-or-beginning-search \
  '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
bindkey -M vicmd vv edit-command-line
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Tools. fzf binds Ctrl-R, Ctrl-T and Alt-C in every keymap, so it follows bindkey -v.
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if [[ "$OSTYPE" == darwin* ]]; then _clip=pbcopy; else _clip='wl-copy'; fi
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | $_clip)+abort' --header 'ctrl-y copies'"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
unset _clip
if (( $+commands[fzf] )); then
  if _fzf_init=$(fzf --zsh 2>/dev/null); then
    eval "$_fzf_init"
  else
    # Ubuntu's fzf predates `fzf --zsh`.
    source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
    source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
  fi
  unset _fzf_init
fi
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

alias python=python3
alias ls=eza
alias ll='eza --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias nano=nvim
alias doctor=dots-doctor
# Permission-bypassing agent modes are explicit opt-ins.
alias codex-yolo='IS_SANDBOX=1 codex --yolo'
alias claude-yolo='IS_SANDBOX=1 claude --dangerously-skip-permissions'

[[ -r "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Plugins from Homebrew or apt. Syntax highlighting must load last.
for _plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for _dir in "${HOMEBREW_PREFIX:-/opt/homebrew}/share/$_plugin" "/usr/share/$_plugin"; do
    [[ -r "$_dir/$_plugin.zsh" ]] && { source "$_dir/$_plugin.zsh"; break; }
  done
done
unset _plugin _dir
