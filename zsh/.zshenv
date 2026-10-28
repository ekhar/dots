# Every zsh reads this, including the `zsh -c` each agent command runs in, which
# does not get options from the agent's shell snapshot.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Agent shells (Claude Code, Codex) handle globs and variables the way bash does,
# which is what models write: an unmatched glob (`grep --include=*.ts`, a URL with
# `?`) stays literal instead of failing the command, and unquoted variables split
# into words.
if [[ -n "$CLAUDECODE$CODEX_THREAD_ID" ]]; then
  setopt NO_NOMATCH SH_WORD_SPLIT
fi
