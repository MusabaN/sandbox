Status: done

# `sandbox --version` scaffold with Homebrew distribution

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

A trivial `sandbox` CLI binary that supports `sandbox --version` (and nothing else), built with `bun build --compile` per ADR-0002, distributed via a working Homebrew tap. The point is to prove the whole distribution pipeline end-to-end — write TypeScript → compile to a single-file executable → install via `brew` → run on macOS and Linux — before we invest in any real features.

No `gh`/`docker` integration. No pickers. Just the binary and the pipeline that ships it.

## Acceptance criteria

- [x] `sandbox --version` prints a version string and exits 0
- [x] The binary is produced by `bun build --compile` and has no runtime dependency on Node or Bun being installed on the host
- [x] A Homebrew formula (in a tap in this repo or a sibling repo) installs the binary such that `sandbox --version` works after `brew install`
- [x] The formula produces working binaries for macOS (Intel and Apple Silicon) and Linux x86_64
- [x] Black-box test: invoke the compiled binary as a subprocess and assert on its stdout and exit code

## Blocked by

None — can start immediately

## Comments

Implemented via TDD (one seam: compile the binary with `Bun.build({compile:true})`,
spawn it as a real subprocess, assert stdout + exit code — `tests/cli.test.ts`).

Decisions made while implementing (issue text left these open):

- **Tap location**: `Formula/` in this repo (not a sibling `homebrew-*` repo).
  Tapped via the explicit-URL form: `brew tap <owner>/sandbox https://github.com/<owner>/sandbox`.
- **Repo/visibility**: pushed to a public repo (`MusabaN/sandbox`) rather than
  `acme-digital/sandbox`, to avoid putting a scaffold-stage repo in the real
  company org. **Follow-up for a human**: transfer to the org
  (or re-point the formula's `homepage`/`url`s) before this is used for real.
- **Version source**: `package.json` `version` field, embedded at compile time
  via a static JSON import (`import { version } from "../package.json" with { type: "json" }`);
  printed as `sandbox <version>`. The release workflow fails fast if the pushed
  tag doesn't match `package.json`'s version.
- **Release pipeline**: `.github/workflows/release.yml` triggers on `v*` tags,
  cross-compiles `bun-darwin-arm64` / `bun-darwin-x64` / `bun-linux-x64` from a
  single `ubuntu-latest` runner (Bun's `--target` cross-compile downloads the
  target's prebuilt runtime rather than needing native toolchains), and
  publishes a GitHub Release with tarballs + checksums.

Verified end-to-end for real, not just locally:

- Tagged and pushed `v0.1.0` → the Release workflow ran and succeeded:
  https://github.com/MusabaN/sandbox/actions/runs/28593601743
- Release with all 3 platform tarballs:
  https://github.com/MusabaN/sandbox/releases/tag/v0.1.0
- `brew tap MusabaN/sandbox https://github.com/MusabaN/sandbox && brew install MusabaN/sandbox/sandbox`
  actually installed and `sandbox --version` printed `sandbox 0.1.0`, exit 0.
  `brew test sandbox` (the formula's own test block) also passed.
- Confirmed the darwin-arm64/darwin-x64/linux-x64 artifacts are genuine native
  binaries for their target (`file` shows Mach-O arm64, Mach-O x86_64, ELF
  x86-64 respectively); ran the darwin-x64 one for real under Rosetta.
- `brew style Formula/sandbox.rb` passes with no offenses.
