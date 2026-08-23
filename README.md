# valentin-dotfiles

Shell + terminal setup built around **tmux as an AI-agent workspace**: one keystroke
spawns Claude Code or Codex in a tiled pane, panes auto-tile, and Ctrl-C kills the
agent without killing the pane.

macOS (brew) and Linux (apt / dnf / pacman).

**Install (human):**

```sh
git clone https://github.com/valentinmili/valentin-dotfiles.git ~/valentin-dotfiles && bash ~/valentin-dotfiles/install.sh
```

**Install (hand it to an agent):**

```sh
claude -p --dangerously-skip-permissions "Clone https://github.com/valentinmili/valentin-dotfiles.git to ~/valentin-dotfiles, run 'bash ~/valentin-dotfiles/install.sh', then run the post-install checklist in SETUP.md §7 and report the results"
# or: codex exec --yolo "<same prompt>"
```

**→ [SETUP.md](SETUP.md) is the full, self-contained guide** — keybindings, agent
attribution, verification checklist, rollback. Paste it into any machine or hand
it to an agent.

## Key features

- **One-keystroke agents** — `M-c` spawns Claude Code, `M-x` spawns Codex, in a
  tiled pane or a tab. Panes auto-tile on open and close.
- **Ctrl-C-safe agent panes** — agents run in a wrapper shell, so killing the
  agent drops back to zsh instead of closing the pane.
- **No prefix key** — every tmux binding is a single Alt chord (`M-hjkl`
  navigate, `M-z` zoom, `M-g` lazygit popup, `M-f` yazi popup, `M-/` help).
- **Works in any macOS terminal** — Ghostty, cmux, Terminal.app, and Zed are
  auto-configured to send Option as Alt; full mouse support everywhere.
- **Commit as yourself, always** — agent commits are authored as `valentinmili`
  with no AI trailers, enforced at four layers (agent instructions, agent
  config, git identity, a global `commit-msg` hook).
- **Modern shell without the framework tax** — starship, autosuggestions,
  syntax highlighting, eza/bat/zoxide/fzf, plain git clones instead of oh-my-zsh.
- **Idempotent installer** — safe to re-run; existing files are backed up, and
  machine-specific config lives in untracked `~/.zshrc.local`.

## Contents

| File | Purpose |
| --- | --- |
| `tmux.conf` | Agent workspace: Alt-key bindings, auto-tiling, lazygit/yazi popups |
| `zshrc` | starship + plugins + modern CLI aliases + agent aliases |
| `gitconfig` | delta pager, diff3 conflicts, rerere, aliases |
| `starship.toml` | Prompt config |
| `claude/settings.json` | Claude Code: commits authored as `valentinmili`, no agent trailers |
| `claude/CLAUDE.md` | Global agent rule: always commit & push as `valentinmili` |
| `codex/config.toml` | Same for Codex |
| `install.sh` | Idempotent installer — deps, plugins, symlinks, attribution |
| `SETUP.md` | Standalone bootstrap doc |

## Quick reference

`M-c` Claude pane · `M-x` Codex pane · `M-C`/`M-X` same as tabs · `M-hjkl` navigate ·
`M-z` zoom · `M-g` lazygit · `M-f` yazi · `M-/` **help popup**

## Terminals (macOS)

The `M-` bindings need Option sent as Alt. The installer sets this up everywhere:

| Terminal | How |
| --- | --- |
| Ghostty | `macos-option-as-alt = true` via the symlinked config |
| cmux | reads the same Ghostty config (≥ 0.64.16) — reload with `Cmd+Shift+,` or restart. Dead-key combos can be eaten there, so `M-m`/`M-s` alias `M-n`/`M-e` |
| Terminal.app | installer enables *Use Option as Meta key* on your default profile |
| Zed | installer sets `terminal.option_as_meta = true` |
| iTerm2 | manual: Profiles → Keys → *Left Option key → Esc+* |

Every commit — yours or any agent's — is authored as `valentinmili` via the GitHub
noreply address, enforced at three layers (git identity, agent config, global
`commit-msg` hook). Details in [SETUP.md §4](SETUP.md#4-agent-commit-attribution).

## Local overrides

`~/.zshrc.local` is sourced if present and never committed. Machine-specific paths,
secrets and work config go there.
