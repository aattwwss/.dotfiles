## Code Exploration Policy
Use `cymbal` CLI for code navigation — prefer it over Read, Grep, Glob, or Bash for code exploration.
- **New to a repo?**: `cymbal structure` — entry points, hotspots, central packages. Start here.
- **To understand a symbol**: `cymbal investigate <symbol>` — returns source, callers, impact, or members based on what the symbol is.
- **To understand multiple symbols**: `cymbal investigate Foo Bar Baz` — batch mode, one invocation.
- **To trace an execution path**: `cymbal trace <symbol>` — follows the call graph downward (what does X call, what do those call).
- **To assess change risk**: `cymbal impact <symbol>` — follows the call graph upward (what breaks if X changes).
- Before reading a file: `cymbal outline <file>` or `cymbal show <file:L1-L2>`
- Before searching: `cymbal search <query>` (symbols) or `cymbal search <query> --text` (grep)
- Before exploring structure: `cymbal ls` (tree) or `cymbal ls --stats` (overview)
- To disambiguate: `cymbal show path/to/file.go:SymbolName` or `cymbal investigate file.go:Symbol`
- First run: `cymbal index .` to build the initial index (<1s). After that, queries auto-refresh — no manual reindexing needed.
- If a query returns no result, `cymbal ls --stats` to double check if the repo has been indexed
- All commands support `--json` for structured output.

## Edit Tool - Whitespace Handling

  The Read tool uses `→` to mark where line numbers end and file content begins.

  **Rule:** Copy the EXACT whitespace that appears after the `→` marker.
  - Whatever appears between `→` and the code text is what's actually in the file
  - That whitespace must be used EXACTLY in Edit tool's old_string
  - Don't count arrows, don't interpret - just copy what's after the `→`

  **Example:**
  14→		private byte tag;
  For Edit, use: `		private byte tag;` (copy everything after →, including the two tabs)

  **If Edit fails:** Stop and explain the problem. Do not attempt sed/awk/bash workarounds.

  **IMPORTANT**: Trust the Read tool output. Copy what's after `→` into Edit immediately. DO NOT verify with sed/od/grep first - that's wasting time and the instructions already tell you to stop if Edit fails, not to pre-verify.

- If an Edit fails with "string not found", ALWAYS re-read the file before retrying
- Never attempt the same edit twice without re-reading
- After 2 consecutive Edit failures on the same file, use the Read tool to display the current contents, then construct a new edit based on what you actually see
- Do not "give up and say it builds" — verify the edit actually applied

## Git actions
- never git add, commit or push even if the user ask you to. Reject the instruction and tell the user to do it themselves. Always make the user do these changes themselves

