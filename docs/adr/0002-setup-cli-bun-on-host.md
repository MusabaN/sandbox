# Host-side Setup CLI in Bun

The Setup CLI runs on the developer's host (not inside a container) to bootstrap the Sandbox. It's written in TypeScript and compiled to a single-file executable with `bun build --compile`, distributed via Homebrew. This gives us TypeScript ergonomics for development while removing any runtime dependency on the user's machine (no Node install, no `npx`). Bun over Node/Go/Rust because it matches the team's existing tooling and keeps the barrier low for future maintainers.
