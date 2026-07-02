Status: ready-for-agent

# `sandbox --version` scaffold with Homebrew distribution

## Parent

`.scratch/sandbox-mvp/PRD.md`

## What to build

A trivial `sandbox` CLI binary that supports `sandbox --version` (and nothing else), built with `bun build --compile` per ADR-0002, distributed via a working Homebrew tap. The point is to prove the whole distribution pipeline end-to-end — write TypeScript → compile to a single-file executable → install via `brew` → run on macOS and Linux — before we invest in any real features.

No `gh`/`docker` integration. No pickers. Just the binary and the pipeline that ships it.

## Acceptance criteria

- [ ] `sandbox --version` prints a version string and exits 0
- [ ] The binary is produced by `bun build --compile` and has no runtime dependency on Node or Bun being installed on the host
- [ ] A Homebrew formula (in a tap in this repo or a sibling repo) installs the binary such that `sandbox --version` works after `brew install`
- [ ] The formula produces working binaries for macOS (Intel and Apple Silicon) and Linux x86_64
- [ ] Black-box test: invoke the compiled binary as a subprocess and assert on its stdout and exit code

## Blocked by

None — can start immediately
