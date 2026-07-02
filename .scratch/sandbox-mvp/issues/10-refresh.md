Status: ready-for-agent

# `sandbox refresh` — reconcile the container's repo set

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

The third top-level command: `sandbox refresh`. It re-runs the team detection + Repo Set Editor flow and reconciles the running container's cloned repo set against the new selection — without recreating the container.

Flow:

1. Preflight — same `gh` / `docker` checks as `init`, plus the container exists.
2. Team detection — same as `init`, including the multi-team picker from slice #03.
3. Repo Set Editor with **refresh-specific pre-selection**:
   - Every Application whose repos are already cloned in the container is pre-checked.
   - Every **newly discovered** Application from team membership (not previously cloned) is **also pre-checked**. Joining a new team pulls in the new stuff by default.
4. Reconciliation, applied **inside the running container**:
   - Any newly selected Application's repos: `git clone` into the standard `/repos/<name>` path.
   - Any de-selected Application's repos: delete the directory.
5. Safety: before deleting a repo's `/repos/<name>` directory, check whether any Session worktree points at it and has uncommitted changes. If so, warn the user and require confirmation before proceeding.
6. Idempotent — running `refresh` twice in a row with no changes is a no-op.

## Acceptance criteria

- [ ] `sandbox refresh` re-runs team detection and shows the Repo Set Editor with the correct pre-selection state (currently-cloned Applications + newly discovered Applications, both pre-checked)
- [ ] Newly selected Applications are `git clone`d into the running container; de-selected Applications are removed
- [ ] Deleting a repo that has an active Session worktree with uncommitted changes prompts for confirmation; declining aborts that deletion without partial-state damage
- [ ] Running `sandbox refresh` twice in a row with no user changes performs no destructive actions on the second run
- [ ] Test seam: host CLI test with stubbed `gh` + `docker` + `git`. Assertions cover pre-selection state given a starting cloned set and stubbed team membership, the reconciliation actions produced, and the uncommitted-work confirmation prompt.

## Blocked by

- `.scratch/sandbox-mvp/issues/04-repo-set-editor-init.md`
- `.scratch/sandbox-mvp/issues/07-worktree-sessions.md`
