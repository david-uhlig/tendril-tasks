# Token hygiene

- Search with `rg`, never `grep -r` or `find .`: rg skips gitignored files and `.claude/worktrees`. Start with `rg -l`, then `rg -n -m5 --max-columns 200` in the files that matter.
- Never search or read generated or minified files: `app/assets/builds/`, `vendor/javascript/`, `node_modules/`, `coverage/`, `log/`, `tmp/`.
- If an output overflows to a `tool-results/*.txt` file, search it or read a slice; never read it whole.
- Check changes with `mise run test:ff <paths>` (`file:line` works) and `mise run lint:changed`.
- Don't `cat` many files in a shell loop; search for what you need.
