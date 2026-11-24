#!/usr/bin/env bash
# PreToolUse hook for Bash|Edit|Write: puts snapshot updates and changes to the
# conventions spec's known violations in front of the user for approval.
# gems/gustwave/AGENTS.md: "Never update a snapshot just to make the spec pass."
set -uo pipefail

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")
reason=

case "$tool" in
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    if grep -qE 'UPDATE_(API|STYLE)_SNAPSHOTS' <<<"$cmd"; then
      reason="This command rewrites Gustwave snapshots. Approve only if the API or class change is intended, not to make a failing spec pass."
    fi
    ;;
  Edit | Write | MultiEdit)
    path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    case "$path" in
      */spec/fixtures/*_snapshots/*)
        reason="This edits a snapshot fixture by hand. Approve only if the change is intended, not to make a failing spec pass."
        ;;
      */gems/gustwave/spec/components/conventions_spec.rb)
        reason="This edits the conventions spec, where known violations and exceptions live. Approve only for a removed violation or a rule change, not to make the spec pass."
        ;;
    esac
    ;;
esac

[ -z "$reason" ] && exit 0

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
