# Every zsh reads this, including the `zsh -c` each agent command runs in, which
# does not get options from the agent's shell snapshot.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Agent shells (Claude Code, Codex) handle globs and variables the way bash does,
# which is what models write: an unmatched glob (`grep --include=*.ts`, a URL with
# `?`) stays literal instead of failing the command, and unquoted variables split
# into words.
# They also get the fleet agent PATH here, since Codex's shell snapshot does not
# carry PATH; .zprofile applies it again after /etc/zprofile reorders PATH.
if [[ -n "$CLAUDECODE$CODEX_THREAD_ID" ]]; then
  setopt NO_NOMATCH SH_WORD_SPLIT
  [[ -r "$HOME/.agents/shell/env.sh" ]] && source "$HOME/.agents/shell/env.sh"
fi
