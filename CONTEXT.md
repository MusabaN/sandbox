# Sandbox

A per-developer Docker container that hosts all the Git repositories a person might need — their team's repos in the `mollerdigital` GitHub organization — and lets them run scoped opencode sessions against subsets of those repos.

## Language

**Sandbox**:
The Docker container itself. The unit a developer starts, enters, and runs opencode inside.
_Avoid_: workspace, environment, dev container

**Setup CLI**:
The host-side command-line tool (`sandbox`) that bootstraps a Sandbox — detects the user's team via the `gh` CLI, clones the team's non-archived repos into the image, and starts the container. Written in TypeScript, compiled with `bun build --compile`.
_Avoid_: installer, wizard

**Team Repos**:
The set of repositories a user's team(s) have access to in the `mollerdigital` GitHub organization, as returned by `gh api orgs/mollerdigital/teams/{slug}/repos`, excluding archived repos. In the MVP this is the *only* source of repos in the Sandbox.

**Shared Repos** _(post-MVP)_:
Repositories that every Sandbox will eventually include regardless of team — the common cloud infrastructure repos. Not part of the MVP. The set will likely come from an org-wide cloud repo that catalogues cross-team infrastructure.
_Avoid_: common repos, global repos

**Session Scope**:
The subset of repositories a single opencode Session is allowed to see. The Sandbox may host many repos on disk, but each Session only exposes a scoped view via a per-Session directory of `git worktree`s. Each worktree is created from a fresh `origin/main` at Session start; concurrent Sessions can hold different branches of the same repo without interfering.
_Avoid_: workspace, project

**Session**:
A single opencode invocation inside the Sandbox, bound to one Session Scope. The Session's working directory is `/sessions/{uuid}/`, containing one `git worktree` per scoped repo. Multiple Sessions can run concurrently, each with its own scope and its own branch state per repo. Uncommitted work lives inside the Session directory and persists until the Session is explicitly deleted.

**Application**:
A logical product (e.g. "checkout", "fleet-portal") that spans multiple repos. Applications are derived from a shared repo-name prefix — e.g. `checkout-api`, `checkout-web`, `checkout-infra` all belong to the `checkout` Application. In the MVP, the prefix is the first token when the repo name is split on `-`. Applications are used to group repos in the Repo Picker.
_Avoid_: product, project, service

**Repo Picker**:
The interactive UI shown at the start of a Session that lets the user choose which repos form the Session Scope. Repos are grouped visually by Application (shared prefix); the user can select at either Application or individual-repo granularity. In the MVP, nothing is pre-selected — the user makes an explicit choice every time. Post-MVP, an LLM may suggest a pre-selection based on the task description.

**Repo Set Editor**:
The interactive UI shown by `sandbox init` and `sandbox refresh` that determines which repos are cloned into the container. Repos are grouped by Application, and selection is **Application-only** — you cannot untick individual repos within an Application. On `init`, all team Applications are pre-selected. On `refresh`, currently-cloned Applications are pre-selected, plus any new Applications discovered from team membership. A single-repo Application (a repo without a shared prefix) becomes a one-item group and works normally.
