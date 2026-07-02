---
status: superseded by ADR-0004
---

# Session scoping via per-session symlink directories

To let a single Sandbox host many repos while giving each opencode Session a narrow view, each Session gets its own scratch directory containing symlinks to only the repos in its Session Scope. Opencode is launched with that directory as `cwd`. Scoping is a soft boundary — opencode can still `cd` out of it if it tries — but it makes the intended working set the path of least resistance and lets multiple concurrent Sessions cheaply have different scopes without container-per-session overhead. Hard isolation (nested containers or permission rules) is deferred until we hit an actual containment problem.

**Superseded:** symlinks meant concurrent sessions would share branch state on the same underlying checkout. Replaced with per-session `git worktree`s — see ADR-0004.
