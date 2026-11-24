#!/usr/bin/env bash
# PreToolUse hook for Bash|Read|Grep|Glob: enforces CLAUDE.md's token hygiene.
# Refuses recursive grep and `find .` (rg skips gitignored files and
# worktrees), and reads of generated folders. Screenshots in tmp/ and
# bin/visual-diff's tmp/visual/ stay readable.
set -uo pipefail

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")

# A repository path into a generated folder: relative, or absolute under the
# main checkout or a worktree, optionally inside a gem or the dummy app.
escape() { sed 's/[][\.*^$()+?{}|]/\\&/g' <<<"$1"; }
main_root=$(cd "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/.." 2>/dev/null && pwd)
roots=
[ -n "$main_root" ] && roots="|$(escape "$main_root")/(\.claude/worktrees/[^/[:space:]]+/)?"
GENERATED='(^|[[:space:]"'"'"'=:]'"$roots"')(\./)?(gems/[^/[:space:]]+/)?(spec/dummy/)?(app/assets/builds|vendor/javascript|node_modules|coverage|log|tmp)/'
ALLOWED='tmp/visual/|\.(png|jpe?g|gif|webp|svg|pdf)([[:space:]"'"'"']|$)'

generated() { grep -qE "$GENERATED" <<<"$1" && ! grep -qE "$ALLOWED" <<<"$1"; }

reason=
case "$tool" in
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    if grep -qE '(^|[;&|(`]|\s)grep\s+([^|;&]*\s)?(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive|--dereference-recursive)(\s|$)' <<<"$cmd"; then
      reason="Search with rg, not grep -r: rg skips gitignored files and .claude/worktrees. Start with rg -l, then rg -n -m5 --max-columns 200 in the files that matter."
    elif grep -qE '(^|[;&|(`]|\s)find\s+\.(\s|$)' <<<"$cmd"; then
      reason="List files with rg --files (add -g '<glob>' to filter), not find .: rg skips gitignored files and .claude/worktrees."
    elif grep -qE '(^|[;&|(`]|\s)(cat|head|tail|less|more|bat|sed|awk|rg|grep|wc|jq)\s' <<<"$cmd" && generated "$cmd"; then
      reason="Don't read or search generated or minified files (app/assets/builds/, vendor/javascript/, node_modules/, coverage/, log/, tmp/). Read the source they're built from."
    fi
    ;;
  Read | Grep | Glob)
    path=$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<<"$input")
    # A Grep or Glob path names a folder, often without its trailing slash; a
    # Glob pattern can name the folder too.
    [ "$tool" = Read ] || path="${path:+${path%/}/}"
    glob=$(jq -r 'if .tool_name == "Glob" then .tool_input.pattern // empty else empty end' <<<"$input")
    if { [ -n "$path" ] && generated "$path"; } || { [ -n "$glob" ] && generated " $glob"; }; then
      reason="Don't read or search generated or minified files (app/assets/builds/, vendor/javascript/, node_modules/, coverage/, log/, tmp/). Read the source they're built from."
    fi
    ;;
esac

[ -z "$reason" ] && exit 0

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
