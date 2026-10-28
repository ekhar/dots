# Agent login shells (Claude Code, Codex): /etc/zprofile's path_helper just moved
# the system dirs to the front, so restore the fleet agent PATH (GNU tools first).
if [[ -n "$CLAUDECODE$CODEX_THREAD_ID" && -r "$HOME/.agents/shell/env.sh" ]]; then
  source "$HOME/.agents/shell/env.sh"
fi

# Login-shell environment.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
