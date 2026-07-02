Status: ready-for-agent

# Sessions use `git worktree` from fresh `origin/main`

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Replace the naive per-Session directory population from slice #05 with real `git worktree` semantics, per ADR-0004.

At Session start, the container launcher does the following for each repo in the (still hardcoded — Repo Picker arrives in slice #09) Session Scope:

1. `git -C /repos/<name> fetch origin` — **best effort**, ignore failures. A developer with no network still gets a Session.
2. `git -C /repos/<name> worktree add /sessions/{uuid}/<name> origin/main`

Opencode is launched with `/sessions/{uuid}/` as `cwd` (unchanged from slice #05).

Session directories **persist across container restarts** — they live on the container's writable layer (or a volume), and stopping/starting the Sandbox does not delete them. They are only removed when the user explicitly deletes them (out of scope here — MVP relies on the user `rm`-ing the directory manually).

## Acceptance criteria

- [ ] Each entry under `/sessions/{uuid}/` for a Session is a `git worktree` of the corresponding repo, pointed at whatever `origin/main` was after the pre-Session `fetch`
- [ ] `git fetch` failure (e.g. no network) does not abort session creation; the worktree is created from whatever `origin/main` is already local
- [ ] Session directories survive a `docker stop` / `docker start` of the Sandbox
- [ ] Uncommitted work inside a Session worktree persists until the Session directory is deleted
- [ ] Test seam: container launcher test uses real `git` against tmpdir fixtures. Assertions cover the commit each worktree is on, that `fetch` failure is non-fatal, and persistence across a simulated container restart.

## Blocked by

- `.scratch/sandbox-mvp/issues/05-chat-scaffolding.md`
