# Git and gh auth via bind-mounted host credentials

The Sandbox container reuses the host user's Git and GitHub credentials rather than managing its own. Specifically:

- SSH-based `git push`/`pull` works via a bind-mounted `SSH_AUTH_SOCK` — keys never enter the container, but the container can sign operations as the user.
- `gh` CLI operations (PRs, issues, API calls) work via a bind-mount of the host's `gh` config directory.

Rejected alternatives:

- **Copy SSH keys into the image or bind-mount `~/.ssh` directly** — a compromised process inside the container could exfiltrate the key material.
- **Container-scoped GitHub App with its own credentials** — cleanest separation but requires registering and maintaining a GitHub App, credential refresh flows, and per-user provisioning. Overkill for the current trust model.
- **Prompt `gh auth login` inside the container** — friction on every rebuild, and doesn't cover SSH.

Consequence: the trust boundary is "code running in the Sandbox can act as the user on GitHub." This is the same boundary as running `npm install` on the host, so it's acceptable — but it's not zero, and hard isolation (own credentials) is the path forward if that changes.
