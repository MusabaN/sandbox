Status: ready-for-agent

# PRD: Sandbox MVP

## Problem Statement

A developer at Måler Digital works across several repositories that belong to their team, plus (eventually) cross-team infrastructure repos. When they want to hand a task to an AI coding agent like opencode, three problems get in the way:

1. **Repo discovery is manual.** New joiners don't know which repos their team owns. Existing team members have local clones scattered across their machine at different levels of freshness.
2. **The agent sees too much.** Pointing opencode at a directory full of 20+ cloned repos gives it 20+ places to grep, most of them irrelevant to the current task. Answers get slower and worse.
3. **Working across repos is awkward.** A task that touches an API repo and its infra repo requires the developer to have both cloned, both up to date, and both visible to the agent — but *only* those two, not everything else on disk.

There is no shared, reproducible way for a developer to say "give me my team's stuff, ready to work on, and let me point an agent at just the repos this task needs."

## Solution

A per-developer **Sandbox** — a Docker container that hosts all the Git repositories the developer's team owns — plus a host-side **Setup CLI** (`sandbox`) that provisions it and manages sessions inside it.

The developer runs `sandbox init` once. The CLI detects their GitHub team memberships in the `mollerdigital` organization (via `gh`), lets them pick the team(s) they belong to, and clones every non-archived repo those teams have access to into the container.

To do work, the developer runs `sandbox chat "…"`, which enters the container and presents an interactive **Repo Picker** — repos grouped by **Application** (repos sharing a `-`-separated prefix, e.g. `checkout-api` / `checkout-web` / `checkout-infra` all belong to the `checkout` Application). The developer picks the exact repos they want in scope. The launcher creates a per-**Session** directory of `git worktree`s pinned to fresh `origin/main` for each scoped repo, and drops the developer into opencode with that directory as the working root.

Multiple Sessions can run concurrently in the same Sandbox, each with its own scope and its own worktrees — so a developer can have a "frontend hotfix" session and a "backend refactor" session open in parallel without them fighting over branch state.

When the developer's team membership changes or they want to trim what's cloned, they run `sandbox refresh` — a **Repo Set Editor** that re-runs the team selection and lets them add or remove whole Applications from the container.

## User Stories

### Setup and provisioning

1. As a developer, I want to install the Setup CLI via Homebrew, so that I don't need Node, Bun, or any other runtime installed on my host.
2. As a developer, I want `sandbox init` to check that `gh` is installed and authenticated before doing anything else, so that I don't hit an obscure failure halfway through setup.
3. As a developer, I want `sandbox init` to auto-detect my team memberships in the `mollerdigital` GitHub organization, so that I don't have to type or remember team slugs.
4. As a developer, I want to see a checklist of every team I'm a member of with all teams pre-checked, so that in the common single-team case I can just press Enter, and in the multi-team case I can uncheck teams whose repos I don't want.
5. As a developer whose GitHub account is in zero Måler Digital teams, I want a clear error message telling me what to do, so that I'm not stuck at a blank picker.
6. As a developer, I want the CLI to fetch all repos accessible to my selected team(s) and filter out archived repos, so that dead code doesn't take up disk or attention.
7. As a developer, I want to see a **Repo Set Editor** during `init` that groups the discovered repos by **Application** (shared `-` prefix), with every Application pre-checked, so that in the default case I just confirm and get everything.
8. As a developer, I want the Repo Set Editor to only offer Application-level selection (not per-repo), so that a whole product's repos are always cloned together and stay consistent.
9. As a developer, I want a repo without a shared prefix (e.g. `dev-tools`) to appear as a one-item Application in the editor, so that standalone repos still work naturally.
10. As a developer, I want `sandbox init` to build a Docker image containing my selected Applications' repos, so that my Sandbox is a single reproducible artifact.
11. As a developer, I want `sandbox init` to be idempotent — if I run it again, it either updates the existing Sandbox or refuses with a clear message pointing me at `sandbox refresh` — so that I don't accidentally destroy my working state.

### Refreshing the repo set

12. As a developer who just joined a new team, I want `sandbox refresh` to re-run the team-selection flow so that I can add my new team's repos without recreating the whole Sandbox.
13. As a developer, I want `sandbox refresh` to show the Repo Set Editor with currently-cloned Applications pre-checked, plus any *newly discovered* Applications from my team membership also pre-checked, so that joining a team pulls in the new stuff by default.
14. As a developer, I want `sandbox refresh` to clone any newly selected Applications and delete any de-selected ones, so that the container's clone set matches what I asked for.
15. As a developer with uncommitted work in a Session worktree, I want `sandbox refresh` to warn me before deleting a repo I have outstanding work in, so that I don't lose changes silently.
16. As a developer, I want `sandbox refresh` to be safe to run repeatedly, so that I can use it to fix up state without fear.

### Running sessions

17. As a developer, I want `sandbox chat "fix the timeout in checkout"` to enter my Sandbox and drop me into a **Repo Picker**, so that a session's scope is chosen at session start, not baked into setup.
18. As a developer, I want the Repo Picker to group repos by Application (same visual model as the Repo Set Editor), so that the UI is consistent.
19. As a developer, I want the Repo Picker to allow per-repo selection within an Application (unlike the Repo Set Editor), so that I can scope a session to just `checkout-api` without pulling in `checkout-web`.
20. As a developer, I want the Repo Picker to have nothing pre-selected in the MVP, so that I make an explicit, deliberate choice every session and don't drift into always-scope-everything habits.
21. As a developer, I want each Session to have its own directory under `/sessions/{uuid}/` inside the container, so that concurrent sessions never share working state.
22. As a developer, I want each scoped repo in a Session to be a `git worktree` created from a freshly-fetched `origin/main`, so that I start every Session on the latest code by default.
23. As a developer working offline, I want Session start to still succeed when `git fetch` fails, using whatever refs are already local, so that no-network isn't a hard blocker.
24. As a developer, I want opencode to launch with the Session directory as its working root, so that its file operations are naturally scoped to the repos I picked.
25. As a developer, I want to open a second terminal, run `sandbox chat "…"` again, and get a separate Session with its own scope and its own worktrees, so that I can multi-task without interference.
26. As a developer, I want uncommitted work in a Session's worktree to persist until I explicitly delete the Session, so that I can pause a task and come back to it.
27. As a developer, I want to push a branch to GitHub from inside a Session, so that I can open a PR when the agent's work is ready.
28. As a developer, I want `gh` commands (open PR, list issues) to work inside a Session using my host's `gh` auth, so that I don't have to log in again inside the container.
29. As a developer, I don't want my host SSH private keys copied into the container, so that a compromised process in the Sandbox can't exfiltrate them.

## Implementation Decisions

### Distribution and runtime

- The **Setup CLI** is written in TypeScript and compiled with `bun build --compile` to a single-file executable per platform. Distributed via Homebrew. No runtime dependency on the user's host. See ADR-0002.
- The Setup CLI shells out to `gh` for all GitHub interactions. `gh` is a hard prerequisite; the CLI checks for it up front and fails fast if it's missing or unauthenticated.
- The Setup CLI shells out to `docker` for image build and container lifecycle. `docker` is a hard prerequisite.

### GitHub interaction

- Team membership discovery uses `gh api /user/teams`, filtered to teams in the `mollerdigital` organization.
- Team repo discovery uses `gh api orgs/mollerdigital/teams/{slug}/repos --paginate`. No filtering by permission level.
- Archived repos are excluded (the `archived` field on the repo API response).
- Multiple selected teams: their repo sets are unioned; duplicates collapse.

### Sandbox container

- One long-lived container per developer, not per session. Multiple concurrent Sessions run *inside* the same container as separate worktree directories. See ADR-0004.
- Repos are cloned into a well-known path inside the container (e.g. `/repos/<name>`). The exact path is an internal detail but stable.
- Container is created and started by `sandbox init`; started (if stopped) by `sandbox chat`. Stopped explicitly by the user or on host restart.
- Authentication into GitHub from inside the container uses two bind-mounts: the host's `SSH_AUTH_SOCK` (for SSH-based `git push`/`pull`) and the host's `gh` config directory (for `gh` CLI operations). SSH keys are not copied into the image. See ADR-0003.

### Applications and grouping

- **Application** grouping is computed by splitting a repo's name on `-` and taking the first token. No stopword list, no override file in the MVP.
- Repos with no `-` in the name form a one-item Application under their own name.
- Applications are computed at UI-render time from the current repo set. There is no persisted `applications.yaml` in the MVP.

### The two pickers

Two distinct interactive UIs, both grouped by Application, that differ in *when* they run and what granularity they offer:

| | Repo Set Editor | Repo Picker |
|-|-|-|
| Runs during | `init`, `refresh` | `chat` |
| Modifies | Container's cloned repos | Session Scope |
| Granularity | Application only | Application or individual repo |
| Pre-selection | All / all-currently-cloned+new | Nothing |
| Effect of "yes" | `git clone` (expensive) | `git worktree add` (cheap) |
| Effect of "no" | Delete repo directory (with worktree warning) | Not included in Session |

Both are implemented on top of the same underlying checklist component. The behavioural differences are configuration, not code duplication.

### Sessions and worktrees

- Each Session gets a UUID. Its working directory is `/sessions/{uuid}/`.
- For each repo in the Session Scope, the launcher runs (conceptually): `git -C /repos/<name> fetch origin` (best-effort, ignore failures), then `git worktree add /sessions/{uuid}/<name> origin/main`.
- Opencode is launched with `/sessions/{uuid}/` as its working directory.
- Session directories persist across container restarts. They are only removed when the user explicitly deletes them.

### Command surface (MVP)

- `sandbox init` — first-time provisioning.
- `sandbox refresh` — re-run team + Repo Set Editor, reconcile container's repo set.
- `sandbox chat "…"` — enter Sandbox, run Repo Picker, start Session, launch opencode.

Additional operational commands (`sandbox stop`, `sandbox rm`, `sandbox sessions ls`) are out of scope for this PRD but are natural extensions.

### The container has two responsibilities

The container ships with a **session launcher** binary that is *separate* from the host Setup CLI. When the host CLI runs `sandbox chat "…"`, it `docker exec`s the container's launcher, passing the task string. The launcher runs the Repo Picker inside the container, sets up the Session directory and worktrees, and execs opencode. This split keeps the host CLI free of any dependency on being able to read `/repos` and keeps worktree operations local to the container's filesystem.

## Testing Decisions

### What makes a good test in this codebase

- Tests treat each binary (host CLI, container launcher) as a black-box process — they invoke it and assert on effects.
- Tests fake external commands (`gh`, `docker`, `git`) via stub binaries on `$PATH`. Stubs record calls and return canned output.
- Tests never inspect the picker UI's TTY output. They inspect the *data the picker was given* and the *effects of the selection*.
- Tests do not couple to internal file paths, function names, or module structure.

### Modules to be tested

- **Host Setup CLI** — one test seam covering `init`, `refresh`, `chat`. Fakes `gh` and `docker`. Assertions:
  - Given fake `gh` output, the correct `docker` commands are invoked.
  - Team detection filters to the `mollerdigital` org.
  - Archived repos are excluded.
  - Repo Set Editor is presented with Applications grouped correctly and the correct pre-selection state.
  - `chat` forwards to the container launcher with the expected arguments.
- **Container session launcher** — one test seam covering the "start a session" entry point. Uses real `git` against tmpdir fixtures to make worktree operations meaningful. Assertions:
  - Given a set of local clones and a chosen Session Scope, the Session directory contains the expected worktrees.
  - Each worktree is on a commit equal to the local `origin/main`.
  - `fetch` failure does not abort session creation.
  - Opencode invocation is issued with the Session directory as its `cwd`.

### Prior art

None in this repo yet — this is greenfield. The pattern (black-box test the binary, stub external commands via `$PATH`) is the same approach used by tools like `git`'s own test suite and CLI projects like `hyperfine`, `fd`, and `bat`.

## Out of Scope

- **Shared Repos / cross-team infra repos.** MVP is team repos only. A future iteration will pull cross-team infrastructure repos from an org-wide catalogue.
- **LLM-suggested pre-selection in the Repo Picker.** MVP has empty pre-selection. Later, a classifier call may propose a scope from the task string, but the user always confirms.
- **Application prefix stopwords or overrides.** Pure `split('-')[0]` in the MVP. Handling collisions like `platform-*` or `shared-*` is deferred until we hit them.
- **Hard isolation between Sessions.** Scoping is a soft boundary — opencode can `cd` out of `/sessions/{uuid}/` if it tries. Nested containers or opencode permission rules are deferred until a containment problem shows up.
- **Container-scoped GitHub credentials.** MVP uses the host user's credentials via bind-mount. A dedicated GitHub App per Sandbox is deferred.
- **Session lifecycle commands** (`sandbox sessions ls`, `resume`, `rm`). MVP relies on users just closing their terminal and manually removing `/sessions/{uuid}/` if they want to.
- **Windows support.** MVP targets macOS and Linux hosts. Windows via WSL should work incidentally but isn't tested.
- **Non-`main` default branches.** MVP assumes `origin/main`. Repos using `master` or another default branch are out of scope.

## Further Notes

- The Setup CLI's name (`sandbox`) is a working title, not a formal shipping name.
- `git worktree` sharing the object store means the marginal disk cost of a Session is small — only the working-tree files are duplicated. This is what makes "one worktree per session per repo" affordable.
- The two-binary split (host CLI + container launcher) is deliberate: it keeps concerns local, and it means the container launcher can evolve independently of Homebrew release cadence.

## Domain vocabulary used in this PRD

Sandbox, Setup CLI, Team Repos, Session Scope, Session, Application, Repo Picker, Repo Set Editor. See `CONTEXT.md`.

## Referenced ADRs

- ADR-0002: Host-side Setup CLI in Bun
- ADR-0003: Git and gh auth via bind-mounted host credentials
- ADR-0004: Session scoping via per-session git worktrees
