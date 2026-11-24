#!/usr/bin/env bash
# PostToolUse hook for Edit|Write: runs RuboCop on the Ruby file Claude just
# changed and hands any offenses back to Claude (exit 2), so they get fixed
# right away instead of surfacing in `mise run lint:changed` later.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
  *.rb | *.rake | *.gemspec | *.ru | */Gemfile | */Rakefile) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

out=$(bin/rubocop --force-exclusion --format emacs -- "$file" 2>&1)
case $? in
  0) exit 0 ;;
  1)
    {
      echo "RuboCop found offenses in $file. Fix them before moving on:"
      echo "$out"
    } >&2
    exit 2
    ;;
  *)
    # RuboCop itself failed (bundler, config). Tell the user, don't block Claude.
    echo "rubocop-file hook: RuboCop could not run on $file: $out" >&2
    exit 1
    ;;
esac
