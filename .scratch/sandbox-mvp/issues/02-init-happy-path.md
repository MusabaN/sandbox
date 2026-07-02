Status: ready-for-agent

# `sandbox init` happy path — one team, all repos, empty container

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Full end-to-end `sandbox init` for the simplest possible case: the user is a member of exactly one team in the `mollerdigital` GitHub organization, `gh` is installed and authenticated, and `docker` is available. No interactive pickers yet — take every non-archived repo the team has access to.

Flow:

1. Preflight — check `gh` is installed and authenticated, and `docker` is available. Fail fast with actionable error messages if not.
2. Call `gh api /user/teams` to find the user's teams, filter to those in the `mollerdigital` org.
3. For the (assumed single) team, call `gh api orgs/mollerdigital/teams/{slug}/repos --paginate` and drop archived repos.
4. Build a Docker image containing the resulting repo set (cloned into a stable well-known path inside the image, e.g. `/repos/<name>`).
5. Start the container.

Idempotency guard: if a Sandbox already exists for this user, `sandbox init` refuses with a clear error message pointing at `sandbox refresh`. It must not silently destroy or recreate an existing Sandbox.

## Acceptance criteria

- [ ] `sandbox init` on a clean host with a single-team user builds an image containing all non-archived repos for that team and starts the container
- [ ] Preflight failures (`gh` missing, `gh` not authenticated, `docker` missing) produce actionable error messages and non-zero exit codes
- [ ] Only repos from teams in the `mollerdigital` org are considered
- [ ] Archived repos are excluded
- [ ] Running `sandbox init` a second time when a Sandbox already exists refuses with a message pointing at `sandbox refresh`, and does not touch the existing container or image
- [ ] Test seam: `gh` and `docker` are stubbed via fake binaries on `$PATH` (recording calls, returning canned output). Assertions cover the `docker build` invocation, the repo list passed to it, and the idempotency-guard behaviour.

## Blocked by

- `.scratch/sandbox-mvp/issues/01-sandbox-version-scaffold.md`
