# SETUP.md — self-contained bootstrap

Everything needed to reproduce this environment on a fresh **macOS** or **Linux**
box. This file is standalone: you can paste it (or just the one-liner below) into
any machine or hand it to an AI agent, with or without cloning the repo.

---

## 1. The one-liner

**Human:**

```sh
git clone https://github.com/valentinmili/configuration.git ~/configuration && bash ~/configuration/install.sh
```

Idempotent — safe to re-run. Existing files are backed up to `*.bak.<timestamp>`.
Open a new shell when it finishes (`exec zsh -l`).

**Agent** (Claude Code headless; same prompt works for Codex via `codex exec --yolo`):

```sh
claude -p --dangerously-skip-permissions "Clone https://github.com/valentinmili/configuration.git to ~/configuration, run 'bash ~/configuration/install.sh', then run the post-install checklist in SETUP.md §7 and report the results"
```

**Over SSH, in one shot:**

```sh
ssh <host> 'git clone https://github.com/valentinmili/configuration.git ~/configuration && bash ~/configuration/install.sh'
```

---

## 2. What gets installed

**Packages** — `zsh git curl tmux`, plus `git-delta lazygit starship fzf bat eza
zoxide yazi ripgrep`. Homebrew on macOS; apt/dnf/pacman on Linux, falling back to
upstream install scripts for tools that distro repos don't carry.

**zsh plugins** — `zsh-autosuggestions` and `zsh-syntax-highlighting`, cloned into
`~/.zsh/`. No oh-my-zsh: it's a framework tax for two plugins.

**tmux plugins** — catppuccin theme, tmux-cpu, tmux-battery, into
`~/.config/tmux/plugins/`.

**Symlinks**

| Repo file | Destination |
| --- | --- |
| `zshrc` | `~/.zshrc` |
| `tmux.conf` | `~/.tmux.conf` |
| `gitconfig` | `~/.gitconfig` |
| `gitignore_global` | `~/.gitignore_global` |
| `starship.toml` | `~/.config/starship.toml` |
| `config/ghostty/config` | `~/.config/ghostty/config` (macOS only) |
| `opencode/opencode.json` | merged into `~/.config/opencode/opencode.json` |

**Terminal Option-as-Alt (macOS)** — Terminal.app gets *Use Option as Meta key*
enabled on the default profile, Zed gets `terminal.option_as_meta = true`
(inserted textually so JSONC comments survive). Ghostty and cmux are covered by
the symlinked Ghostty config. See §3a.

**Agent attribution** — merged into `~/.claude/settings.json` and
`~/.codex/config.toml`, an attribution rule appended to `~/.claude/CLAUDE.md`,
plus a global `commit-msg` hook. See §4.

**OpenCode permissions** — `"permission": "allow"` merged into
`~/.config/opencode/opencode.json` so `o` / `M-o` run with full permissions,
matching `claude --dangerously-skip-permissions` and `codex --yolo`. OpenCode
has no equivalent CLI flag, so this lives in its config file; the merge keeps
any providers or models already configured there.

---

## 3. tmux as an agent workspace

The core of this setup. All bindings are **Alt (`M-`) with no prefix key** — no
`Ctrl-b` chord. Agents run wrapped in `trap : INT; <agent>; exec $SHELL -l`, so
**Ctrl-C kills the agent but leaves the pane alive** with a shell in it.

| Key | Action |
| --- | --- |
| `M-c` / `M-x` / `M-o` / `M-t` | New **pane**: Claude / Codex / OpenCode / shell |
| `M-C` / `M-X` / `M-O` / `M-T` | New **tab**: Claude / Codex / OpenCode / shell |
| `M-n` (or `M-m`) | Menu to pick what to spawn |
| `M-Tab`, `M-[`, `M-]` | Cycle / prev / next tab |
| `M-1`..`M-5` | Jump to tab by number |
| `M-h/j/k/l` | Navigate panes (vim) |
| `M-z` | Zoom / unzoom pane |
| `M-r` | Rotate layout |
| `M-p` | Rename pane (survives agent title spinners) |
| `M-y` | Switch session |
| `M-g` | lazygit popup |
| `M-f` | yazi file-manager popup |
| `M-e` (or `M-s`) | Scroll mode (`j`/`k` scroll, `J`/`K` half-page) |
| `M-w` | Kill pane |
| `M-d` | Detach (session keeps running) |
| `M-R` | Reload config |
| `M-q` | Kill workspace (confirms) |
| `M-/` | **Help popup with this list** |

Panes auto-tile on split and on close. Mouse is on: click to focus, drag borders
to resize, wheel scrolls history, drag-select then `Enter` copies to the system
clipboard.

### 3a. Terminal support (macOS)

The `M-` bindings need the terminal to send **Option as Alt/Meta**. The
installer configures every terminal it can reach:

| Terminal | Mechanism | Notes |
| --- | --- | --- |
| **Ghostty** | `macos-option-as-alt = true` in the symlinked config | works out of the box |
| **cmux** | reads `~/.config/ghostty/config` (cmux ≥ 0.64.16) | reload with `Cmd+Shift+,` or restart cmux after install. Dead-key Option combos (`e i u n` `` ` ``) can be consumed by macOS composition there — that's why `M-m` and `M-s` alias `M-n` and `M-e` |
| **Terminal.app** | installer enables *Use Option as Meta key* on the default & startup profiles | open a **new** window; if Terminal was running during install and the setting reverts, enable it in Settings → Profiles → Keyboard |
| **Zed** | installer inserts `"terminal": { "option_as_meta": true }` into `~/.config/zed/settings.json` | comments in the JSONC file are preserved |
| **iTerm2** | manual | Profiles → Keys → *Left Option key → Esc+* |

---

## 4. Agent commit attribution

Goal: **every commit and push — mine or any AI agent's — is authored by
`valentinmili` with no agent trailers.** Four independent layers, so a gap in
one doesn't leak.

**Layer 0 — agent instructions.** `claude/CLAUDE.md` is appended to
`~/.claude/CLAUDE.md` (idempotent, marker-guarded): a standing rule that every
agent commit and push is authored as `valentinmili` with no AI attribution,
even in repos with a different local git user.

**Layer 1 — git identity** (`gitconfig`)

```gitconfig
[user]
	name = valentinmili
	email = 96443138+valentinmili@users.noreply.github.com
```

The GitHub noreply address keeps your real email out of public commit history
while still linking commits to your account.

**Layer 2 — agent config.** `~/.claude/settings.json` gets:

```json
{
  "attribution": { "commit": "", "pr": "" },
  "includeCoAuthoredBy": false,
  "env": {
    "GIT_AUTHOR_NAME": "valentinmili",
    "GIT_AUTHOR_EMAIL": "96443138+valentinmili@users.noreply.github.com",
    "GIT_COMMITTER_NAME": "valentinmili",
    "GIT_COMMITTER_EMAIL": "96443138+valentinmili@users.noreply.github.com"
  }
}
```

Empty `attribution` strings remove the `Co-Authored-By: Claude` and *Generated
with Claude Code* trailers. The `env` block pins author *and* committer, so
attribution holds even inside a repo with a different local `user.email`. The
installer **merges** this into any existing settings rather than overwriting.

**Layer 3 — global `commit-msg` hook** at `~/.config/git/hooks/commit-msg`, wired
up via `core.hooksPath`. It strips `Co-Authored-By:` lines for Claude, Codex,
Cursor, Copilot, Devin and Aider, plus *Generated with* footers, from every commit
in every repo — a catch-all for agents that ignore the config above.

> ⚠️ Setting `core.hooksPath` globally **overrides per-repo `.git/hooks`**. If a
> project relies on its own hooks (husky, pre-commit), re-enable them locally:
> `git config --local core.hooksPath .git/hooks`

**Verify it works:**

```sh
cd /tmp && rm -rf attrtest && mkdir attrtest && cd attrtest && git init -q
git commit -q --allow-empty -m "$(printf 'test\n\nCo-Authored-By: Claude <noreply@anthropic.com>')"
git log -1 --format='%an <%ae>%n---%n%B'
# Expect: valentinmili <96443138+valentinmili@users.noreply.github.com>
# and NO Co-Authored-By line.
```

---

## 5. git config highlights

- **delta** as pager — side-by-side, line numbers, Dracula syntax theme,
  `navigate = true` (jump hunks with `n`/`N`).
- `merge.conflictstyle = diff3` — shows the common ancestor in conflicts.
- `pull.rebase = true`, `push.autoSetupRemote = true`, `fetch.prune = true`.
- `rerere.enabled = true` — remembers how you resolved a conflict and reapplies it.
- Aliases: `git s`, `git lg`, `git last`, `git amend`, `git undo`, `git wip`.

---

## 6. Shell

Starship prompt (one small TOML, not 1600 generated lines). Aliases: `ls`/`ll`/
`la`/`lt` → eza, `cat` → bat, `lg` → lazygit, `y` → yazi-with-cd-on-exit, `mkcd`,
and git shortcuts `gs gd gl ga gc gp gco`. Agent aliases: `c` (Claude, skip
permissions), `x` (Codex yolo), `o` (OpenCode, full permissions).

**Machine-specific config goes in `~/.zshrc.local`** — sourced if present, never
committed. Put work paths, secrets and per-host tweaks there instead of editing
the tracked `zshrc`.

---

## 7. Post-install checklist

```sh
echo $ZSH_VERSION                  # non-empty
command -v starship delta tmux     # all resolve
git config --get core.pager        # delta
git config --get user.email        # 96443138+valentinmili@users.noreply.github.com
git config --get core.hooksPath    # ~/.config/git/hooks
alias c                            # c=yolo
tmux new -s test                   # then press M-/ for the help popup
```

**Font:** the prompt and tmux status use Nerd Font glyphs, rendered by your
**local** terminal, not the remote host. If you see boxes, install any Nerd Font
(e.g. MesloLGS NF) locally and select it in your terminal.

---

## 8. Rollback

The installer never runs `chsh`, so your login shell is untouched.

```sh
# Restore any backed-up file
mv ~/.zshrc.bak.<timestamp> ~/.zshrc

# Drop the global hook (restores per-repo hooks)
git config --global --unset core.hooksPath

# Linux: undo the bash → zsh auto-launch
cp ~/.bashrc.dotfiles-bak ~/.bashrc
```

---

## 9. Manual install, no script

```sh
D=~/configuration
ln -sf $D/zshrc            ~/.zshrc
ln -sf $D/tmux.conf        ~/.tmux.conf
ln -sf $D/gitconfig        ~/.gitconfig
ln -sf $D/gitignore_global ~/.gitignore_global
mkdir -p ~/.config/git ~/.config/ghostty
ln -sf $D/starship.toml    ~/.config/starship.toml
ln -sf $D/config/ghostty/config ~/.config/ghostty/config

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
mkdir -p ~/.config/tmux/plugins/catppuccin ~/.config/tmux/plugins/tmux-plugins
git clone --depth=1 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
git clone --depth=1 https://github.com/tmux-plugins/tmux-cpu.git ~/.config/tmux/plugins/tmux-plugins/tmux-cpu
git clone --depth=1 https://github.com/tmux-plugins/tmux-battery.git ~/.config/tmux/plugins/tmux-plugins/tmux-battery
```
