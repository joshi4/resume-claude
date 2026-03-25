#!/usr/bin/env bash
# SessionStart hook: records git branch → Claude session ID in
# ~/.claude/branch_lookup.csv so the claude() shell function can
# resume the right session next time.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
CWD=$(echo "$INPUT"        | jq -r '.cwd')

[[ -z "$SESSION_ID" || "$SESSION_ID" == "null" ]] && exit 0

BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
[[ -z "$BRANCH" || "$BRANCH" == "HEAD" ]] && exit 0

CSV="$HOME/.claude/branch_lookup.csv"
touch "$CSV"

# Overwrite any existing entry for this branch with the current session
TMP=$(mktemp)
grep -v "^${BRANCH}," "$CSV" > "$TMP" && mv "$TMP" "$CSV"
echo "${BRANCH},${SESSION_ID}" >> "$CSV"
