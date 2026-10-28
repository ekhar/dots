# Bash on macOS is for agents: Claude Code runs its Bash tool here
# (CLAUDE_CODE_SHELL, set by agent-sync). Interactive use stays in zsh, so this
# only sets the fleet's agent PATH.
[ -r "$HOME/.agents/shell/env.sh" ] && . "$HOME/.agents/shell/env.sh"
