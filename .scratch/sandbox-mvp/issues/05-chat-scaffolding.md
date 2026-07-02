Status: ready-for-agent

# `sandbox chat` scaffolding — enter Sandbox, launch opencode with hardcoded scope

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Introduce the second binary in the system — the **container-side session launcher** — and wire up `sandbox chat "…"` on the host to `docker exec` it.

Scope for this slice: prove the two-binary control flow works. No Repo Picker yet, no `git worktree` yet, no auth plumbing yet.

- Host CLI: `sandbox chat "<task string>"` finds the user's running Sandbox (starting it if stopped), then `docker exec`s the container's launcher with the task string as an argument.
- Container launcher: creates a Session directory at `/sessions/{uuid}/`, populates it with a naive representation of "all cloned repos" (any working stand-in — plain copy or symlink is fine for now; `git worktree` comes in slice #07), then execs `opencode` with the Session directory as its working directory.
- The task string is passed through to opencode as its initial prompt.

The container launcher must be a separate binary that ships **inside the image** (per the PRD's "container has two responsibilities" section) — this slice establishes the split so that future slices can evolve each side independently.

## Acceptance criteria

- [ ] `sandbox chat "some task"` on the host enters the user's Sandbox and lands in opencode with `/sessions/{uuid}/` as the working directory
- [ ] The Sandbox container is auto-started if stopped
- [ ] The task string reaches opencode as its initial prompt
- [ ] The Session directory contains one entry per cloned repo (any working form for now)
- [ ] The container launcher is a distinct binary invoked via `docker exec`, not code embedded in the host CLI
- [ ] Test seam: host CLI test asserts on the `docker exec` invocation (image, args). Container launcher test asserts on the Session directory contents and the `opencode` invocation's `cwd` and args. External commands stubbed on `$PATH`.

## Blocked by

- `.scratch/sandbox-mvp/issues/02-init-happy-path.md`
