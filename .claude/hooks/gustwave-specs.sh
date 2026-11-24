#!/usr/bin/env bash
# Stop hook: when gems/gustwave differs from origin/main, runs the gem's specs
# (about 15 seconds) and keeps Claude from finishing while they fail.
#
# Claude may stop without the check when it ends its turn with a question to
# the user, since specs often fail on purpose halfway through a change.
#
# Loop guards, kept per session in the worktree's git dir:
# - a gem state that already passed or already failed isn't run again, so
#   Claude can stop when it can't fix a failure, and the user sees why;
# - after MAX_BLOCKS failing runs in a row the hook stops blocking.
set -uo pipefail

MAX_BLOCKS=3
GEM=gems/gustwave

input=$(cat)
session=$(jq -r '.session_id // "unknown"' <<<"$input")

# The text Claude ended its turn with: from the hook input when Claude Code
# sends it, otherwise the last assistant text in the transcript.
last_message=$(jq -r '.last_assistant_message // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
if [ -z "$last_message" ] && [ -f "$transcript" ]; then
  last_message=$(tail -n 200 "$transcript" | jq -rs '
    [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text] | last // ""' 2>/dev/null)
fi
last_line=$(grep -v '^[[:space:]]*$' <<<"$last_message" | tail -n 1)
if grep -qiE '^needs input:' <<<"$last_message" || grep -q '?' <<<"$last_line"; then
  exit 0
fi

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
[ -d "$GEM" ] || exit 0

base=$(git merge-base origin/main HEAD 2>/dev/null) || base=HEAD
untracked=$(git ls-files --others --exclude-standard -- "$GEM")
if git diff --quiet "$base" -- "$GEM" && [ -z "$untracked" ]; then
  exit 0
fi

# Fingerprint of the gem's state: the diff plus the untracked files' contents.
fingerprint=$({
  git diff "$base" -- "$GEM"
  git ls-files -z --others --exclude-standard -- "$GEM" | xargs -0 -r sha1sum
} | sha1sum | cut -d' ' -f1)

state_dir="$(git rev-parse --absolute-git-dir)/claude-hooks"
state="$state_dir/gustwave-specs-$session"
mkdir -p "$state_dir"
last_fingerprint= last_result= blocks=0
[ -f "$state" ] && read -r last_fingerprint last_result blocks <"$state"

save() { echo "$fingerprint $1 $2" >"$state"; }

if [ "$fingerprint" = "$last_fingerprint" ]; then
  if [ "$last_result" = fail ]; then
    jq -n '{systemMessage: "Gustwave specs still fail; nothing in the gem changed since Claude was shown the failures."}'
  fi
  exit 0
fi

out=$(cd "$GEM" && SKIP_COVERAGE=1 bundle exec rspec --no-color 2>&1)
if [ $? -eq 0 ]; then
  save pass 0
  exit 0
fi

blocks=$((blocks + 1))
save fail "$blocks"

if [ "$blocks" -gt "$MAX_BLOCKS" ]; then
  jq -n --arg n "$MAX_BLOCKS" '{systemMessage: ("Gustwave specs still fail after " + $n + " attempts; the hook stopped blocking. Run them in gems/gustwave with bundle exec rspec.")}'
  exit 0
fi

# The failures section and the summary, capped so a broken suite doesn't flood the context.
failures=$(sed -n '/^Failures:/,$p' <<<"$out")
[ -n "$failures" ] || failures=$(tail -n 60 <<<"$out")
failures=$(head -c 8000 <<<"$failures")

jq -n --arg failures "$failures" '{
  decision: "block",
  reason: ("The Gustwave specs fail (cd gems/gustwave && bundle exec rspec). Fix the cause, not the spec, and follow the Checking changes section of gems/gustwave/AGENTS.md. If you stopped to ask the user something, end your turn with that question instead:\n\n" + $failures)
}'
