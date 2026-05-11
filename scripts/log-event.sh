#!/usr/bin/env bash
# log-event.sh — append structured Claude Code hook events to memory/run-events.jsonl
# Called by hooks defined in .claude/settings.json. Stdin is the hook payload (JSON).
# Never fails the parent tool: any error here exits 0 silently.

set -u
KIND="${1:-unknown}"

# Resolve project root (cwd is the repo when hooks fire). Bail if memory dir absent.
ROOT="$(pwd)"
EVENTS_FILE="$ROOT/memory/run-events.jsonl"
LOG_FILE="$ROOT/docs/session-log.md"
mkdir -p "$ROOT/memory" "$ROOT/docs" 2>/dev/null || exit 0
touch "$EVENTS_FILE" 2>/dev/null || exit 0

# Read stdin payload (may be empty for some hooks).
PAYLOAD="$(cat 2>/dev/null || true)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# If jq is not installed, log a minimal event and exit. Hooks must not block work.
if ! command -v jq >/dev/null 2>&1; then
  printf '{"ts":"%s","kind":"%s","note":"jq missing; raw payload omitted"}\n' \
    "$TS" "$KIND" >> "$EVENTS_FILE"
  exit 0
fi

# Helper: extract JSON field, fallback to empty string.
get() {
  printf '%s' "$PAYLOAD" | jq -r "$1 // empty" 2>/dev/null
}

SESSION_ID="$(get '.session_id')"
TOOL_NAME="$(get '.tool_name')"

case "$KIND" in
  post_edit)
    FILE_PATH="$(get '.tool_input.file_path')"
    SUCCESS="$(get '.tool_response.success')"
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      --arg session "$SESSION_ID" \
      --arg tool "$TOOL_NAME" \
      --arg file "$FILE_PATH" \
      --arg success "$SUCCESS" \
      '{ts:$ts, kind:$kind, session:$session, tool:$tool, file:$file, success:$success}' \
      >> "$EVENTS_FILE"
    # Trigger static check on .astro / content / src changes — best-effort, async.
    case "$FILE_PATH" in
      *.astro|*/src/*|*/content/*|*.ts|*.json|*.md)
        if [[ -f "$ROOT/scripts/check-site.mjs" ]]; then
          (node "$ROOT/scripts/check-site.mjs" >/dev/null 2>&1 &) || true
        fi
        ;;
    esac
    ;;
  post_bash)
    CMD="$(get '.tool_input.command')"
    EXIT_CODE="$(get '.tool_response.exit_code')"
    # Truncate very long commands to keep the log readable.
    CMD_SHORT="$(printf '%s' "$CMD" | head -c 240)"
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      --arg session "$SESSION_ID" \
      --arg cmd "$CMD_SHORT" \
      --arg exit "$EXIT_CODE" \
      '{ts:$ts, kind:$kind, session:$session, cmd:$cmd, exit_code:$exit}' \
      >> "$EVENTS_FILE"
    ;;
  subagent_stop)
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      --arg session "$SESSION_ID" \
      '{ts:$ts, kind:$kind, session:$session}' \
      >> "$EVENTS_FILE"
    {
      printf '\n## %s — subagent_stop\n' "$TS"
      printf -- '- Session: %s\n' "$SESSION_ID"
    } >> "$LOG_FILE" 2>/dev/null || true
    ;;
  session_stop)
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      --arg session "$SESSION_ID" \
      '{ts:$ts, kind:$kind, session:$session}' \
      >> "$EVENTS_FILE"
    {
      printf '\n## %s — session_stop\n' "$TS"
      printf -- '- Session: %s\n' "$SESSION_ID"
    } >> "$LOG_FILE" 2>/dev/null || true
    ;;
  user_prompt)
    PROMPT="$(get '.prompt')"
    PROMPT_SHORT="$(printf '%s' "$PROMPT" | head -c 200)"
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      --arg session "$SESSION_ID" \
      --arg prompt "$PROMPT_SHORT" \
      '{ts:$ts, kind:$kind, session:$session, prompt:$prompt}' \
      >> "$EVENTS_FILE"
    ;;
  *)
    jq -nc \
      --arg ts "$TS" \
      --arg kind "$KIND" \
      '{ts:$ts, kind:$kind, note:"unknown hook kind"}' \
      >> "$EVENTS_FILE"
    ;;
esac

exit 0
