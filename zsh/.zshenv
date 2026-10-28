# Every zsh reads this. Agents never run zsh: on fleet machines the login shell is
# bash, and Ghostty and tmux start zsh for interactive use.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
