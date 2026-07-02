Status: ready-for-agent

# Auth plumbing — bind-mounted SSH_AUTH_SOCK and gh config

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Wire up the credential bind-mounts described in ADR-0003 so that a developer inside a Session can push branches to GitHub and use `gh` without re-authenticating and without host SSH private keys ever entering the container.

Two bind-mounts, both attached to the Sandbox container:

- The host's `SSH_AUTH_SOCK`, so SSH-based `git push` / `git pull` inside the container are signed by the host's SSH agent. Keys themselves must **not** be copied into the image and `~/.ssh` must **not** be bind-mounted directly.
- The host's `gh` config directory, so `gh` commands (`gh pr create`, `gh issue list`, `gh api …`) inside the container use the host user's authenticated `gh` session.

This affects both container creation (`sandbox init` starts the container with the mounts) and container start (`sandbox chat` starts it if stopped, with the mounts). If `SSH_AUTH_SOCK` is unset on the host, print a warning but continue — `gh` operations still work.

## Acceptance criteria

- [ ] From inside a Session in the Sandbox, `git push origin <branch>` to a repo cloned via SSH succeeds using the host's SSH agent
- [ ] From inside a Session in the Sandbox, `gh` commands work using the host's `gh` auth (e.g. `gh api /user` returns the host user)
- [ ] Host SSH private keys (`~/.ssh/id_*`) are not present inside the container image or filesystem
- [ ] `sandbox chat` on a host with `SSH_AUTH_SOCK` unset prints a clear warning but does not abort; `gh`-based flows still work
- [ ] Test seam: host CLI tests assert on the bind-mount flags in the `docker run` / `docker start` invocation. A smoke test verifies from inside the container that `SSH_AUTH_SOCK` resolves and `gh api /user` succeeds against a fixture.

## Blocked by

- `.scratch/sandbox-mvp/issues/05-chat-scaffolding.md`
