# ─── PATH & Homebrew ────────────────────────────────────────────────────
# This machine has both an ARM (/opt/homebrew) and an Intel (/usr/local)
# Homebrew. Source both; the last one wins on PATH precedence.
# On Apple Silicon, skip the Intel Homebrew when Rosetta can't run x86 code —
# otherwise its x86-only binaries shadow everything with "bad CPU type".
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$_brew" ] || continue
  if [ "$_brew" = /usr/local/bin/brew ] && [ "$(uname -m)" = arm64 ] && \
     ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
    continue
  fi
  eval "$("$_brew" shellenv)"
done
unset _brew

export PATH="$HOME/.local/bin:$PATH"

# ─── History ────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt AUTO_CD INTERACTIVE_COMMENTS

# ─── Completion ─────────────────────────────────────────────────────────
autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# ─── Plugins (installed by install.sh into ~/.zsh) ──────────────────────
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# Syntax highlighting must be sourced last of the plugins.
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─── Modern CLI tools ───────────────────────────────────────────────────
# _has: tool is on PATH *and* actually runs (guards against wrong-arch binaries).
_has() { command -v "$1" >/dev/null && ( "$1" --version ) >/dev/null 2>&1; }
_has zoxide  && eval "$(zoxide init zsh)"
_has fzf     && eval "$(fzf --zsh)" 2>/dev/null
_has eza     && { alias ls='eza --icons --group-directories-first'; alias ll='eza -l --icons --git --group-directories-first'; alias la='eza -la --icons --git --group-directories-first'; alias lt='eza --tree --level=2 --icons'; }
_has bat     && { alias cat='bat --paging=never'; export BAT_THEME="Catppuccin Mocha"; }
_has lazygit && alias lg='lazygit'

# ─── Prompt ─────────────────────────────────────────────────────────────
_has starship && eval "$(starship init zsh)"

# ─── Git shortcuts ──────────────────────────────────────────────────────
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'

# ─── AI agents ──────────────────────────────────────────────────────────
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
# yolo is a script (bin/yolo → ~/.local/bin): claude in bypass-permissions
# mode, started in ~/work when launched from $HOME so the folder-trust prompt
# is answered once ever, not once per session (see SETUP.md §7).
alias c="yolo"
alias x="codex --yolo"
# OpenCode has no skip-permissions flag: full permissions come from
# "permission": "allow" in ~/.config/opencode/opencode.json (see install.sh).
alias o="opencode"

# ─── yazi: cd to the directory you exit in ──────────────────────────────
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ─── mkdir + cd ─────────────────────────────────────────────────────────
function mkcd() { mkdir -p "$1" && cd "$1"; }

# ─── Local machine-specific overrides (not tracked in git) ──────────────
# Put per-machine secrets, PATH tweaks, work config in ~/.zshrc.local
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ─── Language toolchains ────────────────────────────────────────────────
# conda
if [ -f "$HOME/opt/anaconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/opt/anaconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# Google Cloud SDK
[ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# SDKMAN — must stay at the very end of this file
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
