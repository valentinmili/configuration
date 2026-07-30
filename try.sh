# Session-only trial of these dotfiles. Nothing is symlinked or overwritten;
# close the terminal and everything reverts.
#
#   source ~/Documents/hacking-editors/valentin-dotfiles/try.sh
#
# Then start tmux with the repo config:  tmux -f "$DOTFILES/tmux.conf" new -s try

DOTFILES="${DOTFILES:-$(cd "$(dirname "${(%):-%x}")" && pwd)}"
export DOTFILES

# Prompt config lives in the repo, not ~/.config
export STARSHIP_CONFIG="$DOTFILES/starship.toml"

# Load the tracked zshrc into this shell only.
# brew shellenv prints its exports when stdout isn't a tty; keep it quiet.
source "$DOTFILES/zshrc" >/dev/null

# Git settings for this session only — no global config is modified.
# GIT_CONFIG_COUNT/KEY/VALUE are per-process env overrides.
export GIT_CONFIG_COUNT=8
export GIT_CONFIG_KEY_0="core.pager";        export GIT_CONFIG_VALUE_0="delta"
export GIT_CONFIG_KEY_1="interactive.diffFilter"; export GIT_CONFIG_VALUE_1="delta --color-only"
export GIT_CONFIG_KEY_2="delta.navigate";    export GIT_CONFIG_VALUE_2="true"
export GIT_CONFIG_KEY_3="delta.side-by-side"; export GIT_CONFIG_VALUE_3="true"
export GIT_CONFIG_KEY_4="delta.line-numbers"; export GIT_CONFIG_VALUE_4="true"
export GIT_CONFIG_KEY_5="delta.syntax-theme"; export GIT_CONFIG_VALUE_5="Dracula"
export GIT_CONFIG_KEY_6="merge.conflictstyle"; export GIT_CONFIG_VALUE_6="diff3"
export GIT_CONFIG_KEY_7="diff.colorMoved";   export GIT_CONFIG_VALUE_7="default"

# Convenience: launch tmux with the repo config
alias trytmux='tmux -f "$DOTFILES/tmux.conf" new-session -A -s try'

print -P "%F{green}✓%f dotfiles loaded for this session only"
print -P "  starship prompt, eza/bat/zoxide aliases, delta pager"
print -P "  run %F{cyan}trytmux%f to start tmux with the agent workspace"
