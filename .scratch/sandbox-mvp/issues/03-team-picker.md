Status: ready-for-agent

# Team picker for multi-team users

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

Add the interactive team-selection checklist to `sandbox init`. Between preflight and repo discovery, if the user is a member of more than one `acme-digital` team, present a checklist of every team with **all teams pre-checked** so a single-team user still just presses Enter (and in the common single-team case the picker doesn't appear at all — no unnecessary UI).

If the user is in zero `acme-digital` teams, print a clear, actionable error explaining the situation and what they need to do (e.g. ask their manager for team membership, verify they're `gh auth login`ed as the right account), then exit non-zero. Do **not** present an empty picker.

For multi-team selection, the resulting repo sets across selected teams are unioned; duplicates collapse.

## Acceptance criteria

- [ ] Multi-team users see a checklist of all their `acme-digital` teams, all pre-checked; the selection flows through to repo discovery
- [ ] Single-team users get the same behaviour as slice #02 (picker is invisible or trivially confirmable)
- [ ] Zero-team users see an actionable error message and a non-zero exit code; no picker is shown
- [ ] Unioned repo sets from multiple teams collapse duplicates
- [ ] Test seam: assertions cover the team list handed to the picker component and the team slugs that flow to the repo-fetch step. Tests do not inspect picker TTY output.

## Blocked by

- `.scratch/sandbox-mvp/issues/02-init-happy-path.md`
