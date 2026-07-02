# Sandbox

A per-developer Docker container that hosts a developer's team repos and lets
them run scoped opencode sessions against them. See [`CONTEXT.md`](CONTEXT.md)
for the domain vocabulary and [`.scratch/sandbox-mvp/PRD.md`](.scratch/sandbox-mvp/PRD.md)
for the full MVP plan.

This repo currently ships the `sandbox --version` scaffold (issue 01) — the
minimal end-to-end proof of the build → compile → Homebrew distribution
pipeline described in [ADR-0002](docs/adr/0002-setup-cli-bun-on-host.md). No
other functionality exists yet.

## Install

```sh
brew tap MusabaN/sandbox https://github.com/MusabaN/sandbox
brew install MusabaN/sandbox/sandbox
sandbox --version
```

## Develop

Requires [Bun](https://bun.sh).

```sh
bun install
bun test          # black-box: compiles the binary, spawns it, asserts stdout/exit code
bun run build     # produces dist/sandbox for the current platform
```
