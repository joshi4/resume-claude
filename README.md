# resume-claude

Automatically resume your Claude Code session when you return to a git branch.

Run `claude` on a branch you've worked on before — it picks up exactly where you left off, no `/resume` needed.

## Install

```
/plugin install resume-claude
```

Then open a new terminal (or `source ~/.zshrc`) to activate the shell function.

If `resume-claude` isn't found, add this repo as a marketplace first:

```
/plugin marketplace add https://github.com/joshi4/resume-claude
```

Then run `/plugin install resume-claude` again.

## How it works

Two components work together:

**SessionStart hook** (`record-branch-session.sh`) — every time a Claude session starts, records the current git branch → session ID in `~/.claude/branch_lookup.csv`.

**Shell function** (`claude.zsh`) — wraps the `claude` command. Before launching, checks the CSV for a prior session on the current branch. If one exists and the session file is still on disk, passes `--resume <id>` automatically.

The shell function is written to `~/.claude/plugins/data/resume-claude/claude.zsh` and sourced from your `~/.zshrc` on first install.

## Behaviour

| Situation | What happens |
|-----------|-------------|
| Feature branch with a prior session | Resumes automatically |
| Feature branch, first time | Starts fresh; session recorded for next time |
| `main` or `master` | Always starts fresh |
| Detached HEAD or non-git directory | Starts fresh |
| Stale session (file deleted) | Clears the CSV entry, starts fresh |
| Bypass | `command claude` skips the function |

## Files

| Path | Purpose |
|------|---------|
| `~/.claude/branch_lookup.csv` | Maps `branch,session_id` — auto-managed, safe to delete |
| `~/.claude/plugins/data/resume-claude/claude.zsh` | Shell function, sourced from `.zshrc` |

## Uninstall

```
/plugin uninstall resume-claude
```

Then remove the `source` line added to your `~/.zshrc` and optionally delete `~/.claude/branch_lookup.csv`.
