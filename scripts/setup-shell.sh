#!/usr/bin/env bash
# Runs on SessionStart. Writes the claude() shell function to a persistent
# location and sources it from ~/.zshrc (once).

PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/resume-claude}"
mkdir -p "$PLUGIN_DATA"

FUNC_FILE="$PLUGIN_DATA/claude.zsh"

# Write the shell function — overwrites on each plugin update so it stays current
cat > "$FUNC_FILE" << 'EOF'
# resume-claude: auto-resume Claude Code sessions by git branch
function claude() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if [[ -n "$branch" && "$branch" != "HEAD" && "$branch" != "main" && "$branch" != "master" ]]; then
    local csv="$HOME/.claude/branch_lookup.csv"
    if [[ -f "$csv" ]]; then
      local session_id
      session_id=$(awk -F',' -v b="$branch" '$1 == b { id=$2 } END { print id }' "$csv")
      if [[ -n "$session_id" ]]; then
        # Verify the session file exists before attempting resume
        local encoded_cwd session_file
        encoded_cwd=$(pwd | tr '/' '-')
        session_file="$HOME/.claude/projects/${encoded_cwd}/${session_id}.jsonl"
        if [[ -f "$session_file" ]]; then
          command claude --resume "$session_id" "$@"
          return
        else
          # Stale entry — remove it so the next run starts fresh
          local tmp
          tmp=$(mktemp)
          grep -v "^${branch}," "$csv" > "$tmp" && mv "$tmp" "$csv"
        fi
      fi
    fi
  fi

  command claude "$@"
}
EOF

# Add source line to ~/.zshrc once
ZSHRC="$HOME/.zshrc"
if ! grep -qF "resume-claude/claude.zsh" "$ZSHRC" 2>/dev/null; then
  printf '\n# resume-claude: auto-resume Claude Code sessions by git branch\nsource "%s"\n' "$FUNC_FILE" >> "$ZSHRC"
fi
