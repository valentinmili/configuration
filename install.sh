#!/usr/bin/env bash
# valentin-dotfiles installer — idempotent, safe to re-run.
# macOS (brew) and Linux (apt / dnf / pacman).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

GIT_NAME="valentinmili"
GIT_EMAIL="96443138+valentinmili@users.noreply.github.com"

say()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }

backup() {
  local f="$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mv "$f" "$f.bak.$TS"
    warn "backed up $f -> $f.bak.$TS"
  elif [ -L "$f" ]; then
    rm "$f"
  fi
}

link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  [ -e "$src" ] || { warn "missing $src — skipped"; return; }
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}

# ─── 1. Dependencies ─────────────────────────────────────────────────────
PKGS_CORE="zsh git curl tmux"
PKGS_NICE="git-delta lazygit starship fzf bat eza zoxide yazi ripgrep"

say "Installing packages…"
if [ "$OS" = "Darwin" ]; then
  if ! command -v brew >/dev/null; then
    say "Installing Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  # shellcheck disable=SC2086
  brew install $PKGS_CORE $PKGS_NICE 2>/dev/null || warn "some brew packages failed — continuing"
elif command -v apt-get >/dev/null; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $PKGS_CORE ripgrep fzf bat || true
  # Packages not reliably in apt: install via their own channels.
  command -v delta    >/dev/null || warn "git-delta: install from https://github.com/dandavison/delta/releases"
  command -v lazygit  >/dev/null || warn "lazygit: install from https://github.com/jesseduffield/lazygit/releases"
  command -v starship >/dev/null && ok "starship present" || \
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  command -v zoxide   >/dev/null || curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  # Debian ships bat as batcat and eza may be absent.
  [ -x /usr/bin/batcat ] && [ ! -e "$HOME/.local/bin/bat" ] && \
    mkdir -p "$HOME/.local/bin" && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
elif command -v dnf >/dev/null; then
  sudo dnf install -y $PKGS_CORE git-delta ripgrep fzf bat eza zoxide || true
  command -v starship >/dev/null || curl -fsSL https://starship.rs/install.sh | sh -s -- -y
elif command -v pacman >/dev/null; then
  sudo pacman -S --needed --noconfirm $PKGS_CORE git-delta lazygit starship fzf bat eza zoxide yazi ripgrep || true
else
  warn "Unknown package manager — install manually: $PKGS_CORE $PKGS_NICE"
fi

# ─── 2. zsh plugins (no oh-my-zsh — plain git clones) ────────────────────
mkdir -p "$HOME/.zsh"
[ ! -d "$HOME/.zsh/zsh-autosuggestions" ] && \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.zsh/zsh-autosuggestions" >/dev/null 2>&1 && ok "zsh-autosuggestions"
[ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ] && \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$HOME/.zsh/zsh-syntax-highlighting" >/dev/null 2>&1 && ok "zsh-syntax-highlighting"

# ─── 3. tmux plugins ─────────────────────────────────────────────────────
TMUX_PLUGINS="$HOME/.config/tmux/plugins"
mkdir -p "$TMUX_PLUGINS/catppuccin" "$TMUX_PLUGINS/tmux-plugins"
[ ! -d "$TMUX_PLUGINS/catppuccin/tmux" ] && \
  git clone --depth=1 https://github.com/catppuccin/tmux.git \
    "$TMUX_PLUGINS/catppuccin/tmux" >/dev/null 2>&1 && ok "catppuccin/tmux"
[ ! -d "$TMUX_PLUGINS/tmux-plugins/tmux-cpu" ] && \
  git clone --depth=1 https://github.com/tmux-plugins/tmux-cpu.git \
    "$TMUX_PLUGINS/tmux-plugins/tmux-cpu" >/dev/null 2>&1 && ok "tmux-cpu"
[ ! -d "$TMUX_PLUGINS/tmux-plugins/tmux-battery" ] && \
  git clone --depth=1 https://github.com/tmux-plugins/tmux-battery.git \
    "$TMUX_PLUGINS/tmux-plugins/tmux-battery" >/dev/null 2>&1 && ok "tmux-battery"

# ─── 4. Symlink configs ──────────────────────────────────────────────────
say "Symlinking configs…"
link zshrc            .zshrc
link tmux.conf        .tmux.conf
link gitconfig        .gitconfig
link gitignore_global .gitignore_global
link starship.toml    .config/starship.toml
[ "$OS" = "Darwin" ] && link config/ghostty/config .config/ghostty/config

# ─── 4b. Option-as-Alt (macOS terminals) ─────────────────────────────────
# The M- tmux bindings need the terminal to send Option as Alt/Meta.
#   Ghostty      — via the config symlinked above (macos-option-as-alt = true)
#   cmux         — reads ~/.config/ghostty/config (>= 0.64.16); reload with
#                  Cmd+Shift+, or restart cmux. Dead-key combos (M-e, M-n)
#                  may still be eaten there — M-s / M-m are bound as aliases.
#   Terminal.app — "Use Option as Meta key", set below
#   Zed          — terminal.option_as_meta, set below
#   iTerm2       — manual: Profiles → Keys → Left Option key → Esc+
if [ "$OS" = "Darwin" ]; then
  say "Configuring Option-as-Alt…"

  # Terminal.app: enable on the default & startup profiles. Round-trip through
  # defaults export/import so cfprefsd stays in sync.
  if defaults read com.apple.Terminal "Default Window Settings" >/dev/null 2>&1; then
    TPLIST="$(mktemp)"
    defaults export com.apple.Terminal "$TPLIST"
    if python3 - "$TPLIST" <<'PY'
import plistlib, sys
p = sys.argv[1]
with open(p, "rb") as f:
    d = plistlib.load(f)
ws = d.get("Window Settings", {})
targets = {d.get("Default Window Settings"), d.get("Startup Window Settings")} & set(ws)
for name in targets or set(ws):
    ws[name]["useOptionAsMetaKey"] = True
with open(p, "wb") as f:
    plistlib.dump(d, f)
PY
    then
      defaults import com.apple.Terminal "$TPLIST"
      ok "Terminal.app: Use Option as Meta key (open a NEW Terminal window; if it reverts, enable in Settings → Profiles → Keyboard)"
    else
      warn "Terminal.app: enable Settings → Profiles → Keyboard → 'Use Option as Meta key' manually"
    fi
    rm -f "$TPLIST"
  else
    warn "Terminal.app: enable Settings → Profiles → Keyboard → 'Use Option as Meta key' manually"
  fi

  # Zed: settings.json is JSONC (comments, trailing commas) — insert textually
  # so user comments survive.
  ZED="$HOME/.config/zed/settings.json"
  if [ ! -f "$ZED" ]; then
    mkdir -p "$(dirname "$ZED")"
    printf '{\n  "terminal": { "option_as_meta": true }\n}\n' > "$ZED"
    ok "Zed: settings.json created with option_as_meta"
  elif grep -q '"option_as_meta"' "$ZED"; then
    ok "Zed: option_as_meta already set"
  else
    python3 - "$ZED" <<'PY' && ok "Zed: option_as_meta added" || warn 'Zed: add "terminal": { "option_as_meta": true } to settings.json manually'
import re, sys
p = sys.argv[1]
s = open(p).read()
m = re.search(r'"terminal"\s*:\s*\{', s)
if m:
    s = s[:m.end()] + ' "option_as_meta": true,' + s[m.end():]
else:
    m = re.search(r'\{', s)
    if not m:
        sys.exit(1)
    s = s[:m.end()] + '\n  "terminal": { "option_as_meta": true },' + s[m.end():]
open(p, "w").write(s)
PY
  fi
fi

# ─── 5. Agent commit attribution ─────────────────────────────────────────
# Every AI coding agent commits as valentinmili with no agent trailers.
say "Configuring agent commit attribution…"

# 5a. Claude Code settings — merge, never clobber existing keys.
mkdir -p "$HOME/.claude"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if command -v python3 >/dev/null; then
  python3 - "$CLAUDE_SETTINGS" "$DOTFILES/claude/settings.json" <<'PY'
import json, sys, os
dst, src = sys.argv[1], sys.argv[2]
new = json.load(open(src))
new.pop("$comment", None)
cur = {}
if os.path.exists(dst):
    try:
        cur = json.load(open(dst))
    except Exception:
        os.rename(dst, dst + ".bak")
for k, v in new.items():
    if isinstance(v, dict):
        cur.setdefault(k, {})
        if isinstance(cur[k], dict):
            cur[k].update(v)
        else:
            cur[k] = v
    else:
        cur[k] = v
json.dump(cur, open(dst, "w"), indent=2)
open(dst, "a").write("\n")
PY
  ok "~/.claude/settings.json updated (attribution stripped)"
else
  warn "python3 missing — copy claude/settings.json into ~/.claude/settings.json manually"
fi

# 5b. Codex config
mkdir -p "$HOME/.codex"
if [ ! -f "$HOME/.codex/config.toml" ]; then
  cp "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"
  ok "~/.codex/config.toml created"
elif ! grep -q "96443138+valentinmili" "$HOME/.codex/config.toml" 2>/dev/null; then
  cat "$DOTFILES/codex/config.toml" >> "$HOME/.codex/config.toml"
  ok "~/.codex/config.toml appended"
fi

# 5c. Global CLAUDE.md rule — every agent commit/push is authored as valentinmili.
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MD_MARKER="valentin-dotfiles: attribution rule"
if [ ! -f "$CLAUDE_MD" ] || ! grep -qF "$MD_MARKER" "$CLAUDE_MD"; then
  [ -f "$CLAUDE_MD" ] && printf '\n' >> "$CLAUDE_MD"
  cat "$DOTFILES/claude/CLAUDE.md" >> "$CLAUDE_MD"
  ok "~/.claude/CLAUDE.md: attribution rule added"
fi

# 5d. Belt-and-braces: a global commit-msg hook that strips agent trailers
#     from EVERY commit, whichever tool made it.
HOOKS_DIR="$HOME/.config/git/hooks"
mkdir -p "$HOOKS_DIR"
cat > "$HOOKS_DIR/commit-msg" <<'HOOK'
#!/usr/bin/env bash
# Strip AI-agent attribution trailers so all commits read as the repo owner.
f="$1"
[ -f "$f" ] || exit 0
tmp="$(mktemp)"
grep -viE '^[[:space:]]*(Co-Authored-By:[[:space:]]*(Claude|Codex|Cursor|Copilot|Devin|Aider)|(🤖[[:space:]]*)?Generated with[[:space:]]+\[?(Claude Code|Codex))' "$f" > "$tmp"
# Collapse trailing blank lines left behind by the removal.
awk 'BEGIN{n=0} {lines[NR]=$0} END{last=NR; while(last>0 && lines[last] ~ /^[[:space:]]*$/) last--; for(i=1;i<=last;i++) print lines[i]}' "$tmp" > "$f"
rm -f "$tmp"
exit 0
HOOK
chmod +x "$HOOKS_DIR/commit-msg"
# Tilde form on purpose: ~/.gitconfig is a symlink into the repo, so an
# absolute path here would commit a machine-specific path. Git expands ~.
git config --global core.hooksPath "~/.config/git/hooks"
ok "global commit-msg hook installed (strips agent trailers)"

# 5e. Make sure identity is set globally even if ~/.gitconfig was skipped.
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
ok "git identity: $GIT_NAME <$GIT_EMAIL>"

# ─── 6. Linux: auto-launch zsh from interactive bash ─────────────────────
# No chsh — the login shell stays bash so non-interactive tooling is unaffected.
if [ "$OS" = "Linux" ] && [ -f "$HOME/.bashrc" ]; then
  MARKER="# >>> dotfiles auto-launch zsh"
  if ! grep -qF "$MARKER" "$HOME/.bashrc"; then
    [ ! -f "$HOME/.bashrc.dotfiles-bak" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.dotfiles-bak"
    cat >> "$HOME/.bashrc" <<'EOF'

# >>> dotfiles auto-launch zsh
[ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null && exec zsh -l
# <<<
EOF
    ok "auto-launch zsh added to ~/.bashrc"
  fi
fi

echo
ok "Done. Open a new shell (or: exec zsh -l)"
echo "   Machine-specific config goes in ~/.zshrc.local (never committed)."
