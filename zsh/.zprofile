# Login-shell environment. Homebrew's paths are written out rather than taken from
# `brew shellenv`, which costs about 20 ms per shell.
typeset -U path fpath
if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
# Child shells that skip .zprofile keep these completion directories.
export FPATH
