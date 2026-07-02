Status: ready-for-agent

# Repo Set Editor grouped by Application (during `init`)

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Add the **Repo Set Editor** to `sandbox init`, run after team selection and repo discovery, before the Docker image build. See CONTEXT.md for the Application/Repo Set Editor vocabulary.

Behaviour:

- Repos are grouped by **Application** — the first token when splitting the repo name on `-`. A repo with no `-` becomes a one-item Application under its own name.
- Selection granularity is **Application only** — the user cannot un-tick individual repos within an Application. A whole product's repos are always cloned together.
- All discovered Applications are pre-checked. In the default case the user just confirms.
- The selected Applications' repos are what gets baked into the Docker image.

Application grouping is computed at UI-render time from the current repo set. No persisted `applications.yaml`, no stopwords, no overrides — pure `split('-')[0]`.

## Acceptance criteria

- [ ] After team selection, the Repo Set Editor is shown with Applications grouped correctly (first `-`-separated token) and all pre-checked
- [ ] Standalone repos (no `-`) appear as one-item Applications
- [ ] Selection is Application-level only; individual repos within an Application cannot be un-ticked
- [ ] The repos in the selected Applications are what flows into `docker build`; de-selected Applications' repos do not appear in the image
- [ ] Test seam: assertions cover the Application groups computed from a stubbed repo list, the pre-selection state passed to the picker, and the final repo list handed to `docker build`. Tests do not inspect picker TTY output.

## Blocked by

- `.scratch/sandbox-mvp/issues/02-init-happy-path.md`
