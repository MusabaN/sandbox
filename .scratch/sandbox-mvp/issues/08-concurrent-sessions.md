Status: ready-for-agent

# Concurrent sessions coexist

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Prove — and where needed, fix — that two `sandbox chat` invocations against the same Sandbox produce two independent Sessions with independent worktrees. A developer must be able to have a "frontend hotfix" Session and a "backend refactor" Session open in parallel without them fighting over branch state.

Specifically:

- Two concurrent Sessions scoped to the same repo can hold different branches at the same time (each worktree has its own `HEAD`).
- Session UUID / directory creation is race-free — two `sandbox chat` calls that fire simultaneously never end up in the same `/sessions/{uuid}/` directory.
- End-to-end verification of `git push origin <branch>` from inside a Session using the SSH agent from slice #06.

This slice is small in code (the design in #07 already supports it) but explicit in verification, so we don't discover the failure later.

## Acceptance criteria

- [ ] Two concurrent Sessions in the same Sandbox each get a distinct `/sessions/{uuid}/`
- [ ] Two Sessions scoped to the same repo can each `git checkout` a different branch in their own worktree; neither affects the other's `HEAD`
- [ ] `git push origin <branch>` from inside a Session succeeds end-to-end against a fixture remote
- [ ] Test seam: launcher test spawns two Sessions in parallel against the same fixture repo, then asserts on the two worktrees' `HEAD`s and directory paths. Push is verified against a bare-repo fixture on the local filesystem.

## Blocked by

- `.scratch/sandbox-mvp/issues/06-auth-bind-mounts.md`
- `.scratch/sandbox-mvp/issues/07-worktree-sessions.md`
