# Session scoping via per-session git worktrees

Each Session gets its own directory `/sessions/{uuid}/` populated with `git worktree add` entries for each repo in its Session Scope. Opencode is launched with that directory as `cwd`. Compared to the original symlink approach (ADR-0001), worktrees give each Session an independent working tree and branch state, so concurrent Sessions scoped to the same repo don't fight over `HEAD`.

At Session start, the launcher `git fetch`es each scoped repo (best-effort — offline is non-fatal) and creates the worktrees from `origin/main`. Uncommitted work stays inside the Session's worktree directory until the Session is deleted; it doesn't leak into other Sessions or into the base clone.

Disk cost is bounded — worktrees share the underlying `.git` object store with the base clone, so only working-tree files are duplicated per Session. Scoping is still a soft boundary (opencode can `cd` out); hard isolation is deferred.
