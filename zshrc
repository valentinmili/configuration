# ─── PATH & Homebrew ────────────────────────────────────────────────────
# This machine has both an ARM (/opt/homebrew) and an Intel (/usr/local)
# Homebrew. Source both; the last one wins on PATH precedence.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$_brew" ] && eval "$("$_brew" shellenv)"
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
command -v zoxide  >/dev/null && eval "$(zoxide init zsh)"
command -v fzf     >/dev/null && eval "$(fzf --zsh)" 2>/dev/null
command -v eza     >/dev/null && { alias ls='eza --icons --group-directories-first'; alias ll='eza -l --icons --git --group-directories-first'; alias la='eza -la --icons --git --group-directories-first'; alias lt='eza --tree --level=2 --icons'; }
command -v bat     >/dev/null && { alias cat='bat --paging=never'; export BAT_THEME="Catppuccin Mocha"; }
command -v lazygit >/dev/null && alias lg='lazygit'

# ─── Prompt ─────────────────────────────────────────────────────────────
command -v starship >/dev/null && eval "$(starship init zsh)"

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
alias yolo="claude --dangerously-skip-permissions"
alias c="yolo"
alias x="codex --yolo"

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

# SDKMAN — must stay at the very end of this file
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
