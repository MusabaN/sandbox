Status: ready-for-agent

# Repo Picker at Session start (with per-repo granularity)

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Add the **Repo Picker** to the container launcher, run before Session directory creation. See CONTEXT.md for the Repo Picker vocabulary and how it contrasts with the Repo Set Editor.

Behaviour:

- Same Application grouping as the Repo Set Editor (first `-`-separated token; standalone repos are one-item Applications). Implemented on top of the same underlying checklist component as the Repo Set Editor — differences are configuration, not code duplication.
- **Unlike** the Repo Set Editor: the user can select at either Application or **individual-repo** granularity within an Application. A developer can scope a Session to just `checkout-api` without pulling in `checkout-web`.
- **Nothing is pre-selected.** MVP demands an explicit choice every Session. Rationale in the PRD's Out of Scope section — LLM-suggested pre-selection is deferred.
- The task string from `sandbox chat "…"` is available to the launcher (and eventually to a classifier), but for this slice is only used as opencode's initial prompt.
- The selected repo set becomes the Session Scope for the worktree logic from slice #07.

## Acceptance criteria

- [ ] `sandbox chat "<task>"` shows the Repo Picker with Applications grouped correctly and nothing pre-selected
- [ ] The user can toggle either a whole Application or an individual repo within an Application
- [ ] The selected repos become the Session Scope; only those become worktrees under `/sessions/{uuid}/`
- [ ] The Application-grouping logic in the picker shares its implementation with the Repo Set Editor (no duplicate `split('-')[0]` code paths)
- [ ] Test seam: launcher test asserts on the Application/repo groups handed to the picker, on the nothing-pre-selected state, and on which repos become the Session Scope after a stubbed selection. Tests do not inspect picker TTY output.

## Blocked by

- `.scratch/sandbox-mvp/issues/07-worktree-sessions.md`
