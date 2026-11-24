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
    # AGENTS.md: "Don't change a status unless asked." Adding one to a new class is fine.
    if [ -z "$reason" ]; then
      if [ "$tool" = Write ]; then
        before=$(cat -- "$path" 2>/dev/null)
        after=$(jq -r '.tool_input.content // empty' <<<"$input")
      else
        before=$(jq -r '[.tool_input.old_string, (.tool_input.edits // [])[].old_string] | map(select(. != null)) | join("\n")' <<<"$input")
        after=$(jq -r '[.tool_input.new_string, (.tool_input.edits // [])[].new_string] | map(select(. != null)) | join("\n")' <<<"$input")
      fi
      statuses() { grep -oE '@status[[:space:]]+[a-z]+' <<<"$1" | tr -s '[:space:]' ' '; }
      old_status=$(statuses "$before") new_status=$(statuses "$after")
      if [ -n "$old_status" ] && [ "$old_status" != "$new_status" ]; then
        reason="This changes a component's @status (${old_status//@status /} → ${new_status//@status /}). Status changes follow docs/design.md's lifecycle; approve only if you asked for it."
      fi
    fi
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
