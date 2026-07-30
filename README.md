# valentin-dotfiles

Shell + terminal setup built around **tmux as an AI-agent workspace**: one keystroke
spawns Claude Code or Codex in a tiled pane, panes auto-tile, and Ctrl-C kills the
agent without killing the pane.

macOS (brew) and Linux (apt / dnf / pacman).

```sh
git clone https://github.com/valentinmili/valentin-dotfiles.git ~/dotfiles && bash ~/dotfiles/install.sh
```

**→ [SETUP.md](SETUP.md) is the full, self-contained guide** — keybindings, agent
attribution, verification checklist, rollback. Paste it into any machine or hand
it to an agent.

## Contents

| File | Purpose |
| --- | --- |
| `tmux.conf` | Agent workspace: Alt-key bindings, auto-tiling, lazygit/yazi popups |
| `zshrc` | starship + plugins + modern CLI aliases + agent aliases |
| `gitconfig` | delta pager, diff3 conflicts, rerere, aliases |
| `starship.toml` | Prompt config |
| `claude/settings.json` | Claude Code: commits authored as `valentinmili`, no agent trailers |
| `codex/config.toml` | Same for Codex |
| `install.sh` | Idempotent installer — deps, plugins, symlinks, attribution |
| `SETUP.md` | Standalone bootstrap doc |

## Quick reference

`M-c` Claude pane · `M-x` Codex pane · `M-C`/`M-X` same as tabs · `M-hjkl` navigate ·
`M-z` zoom · `M-g` lazygit · `M-f` yazi · `M-/` **help popup**

Every commit — yours or any agent's — is authored as `valentinmili` via the GitHub
noreply address, enforced at three layers (git identity, agent config, global
`commit-msg` hook). Details in [SETUP.md §4](SETUP.md#4-agent-commit-attribution).

## Local overrides

`~/.zshrc.local` is sourced if present and never committed. Machine-specific paths,
secrets and work config go there.
