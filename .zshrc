# In devcontainers, sometimes there's a rogue $HISTFILE that messes with the history plugin
if [[ -v OVERRIDE_HISTFILE ]]; then
  export HISTFILE="$OVERRIDE_HISTFILE"
fi

# Configure the history plugin to respect $HISTFILE if it's configured
if [[ -v HISTFILE ]]; then
  zstyle ':zephyr:plugin:history' histfile "$HISTFILE"
fi

# Antidote
# https://antidote.sh
source ${ANTIDOTE_DIR:-/usr/share/zsh-antidote}/antidote.zsh
antidote load

# History search
# Must come after `antidote load`: it overrides the zephyr editor plugin's Up/Down
# and needs zsh-history-substring-search's widgets to already exist.
#
#   Up/Down       prefix match  - entries STARTING with what you typed
#   Ctrl+Up/Down  substring match - entries CONTAINING what you typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind the normal (^[[A) and application (^[OA) cursor-key sequences so the
# bindings hold regardless of whether the terminal is in keypad transmit mode.
# Ctrl+arrow is ^[[1;5A on xterm/iTerm2, ^[[5A on rxvt.
_bind_hist() {  # $1 = widget, $2... = key sequences
  local widget=$1; shift
  local seq keymap
  for seq in "$@"; do
    for keymap in main viins vicmd; do
      bindkey -M $keymap "$seq" $widget
    done
  done
}

_bind_hist up-line-or-beginning-search   '^[[A' '^[OA'
_bind_hist down-line-or-beginning-search '^[[B' '^[OB'

if (( $+widgets[history-substring-search-up] )); then
  _bind_hist history-substring-search-up   '^[[1;5A' '^[[5A' '^[O5A'
  _bind_hist history-substring-search-down '^[[1;5B' '^[[5B' '^[O5B'
fi

unfunction _bind_hist

# User binaries
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH=$HOME/.local/bin:$PATH
fi

# Use Windows browser in WSL
if command -v wslview &> /dev/null; then
  export BROWSER=wslview
fi

# uv
if command -v uv &> /dev/null; then
  source <(uv generate-shell-completion zsh)
fi

# Kubernetes
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# Helm
if command -v helm &> /dev/null; then
  source <(helm completion zsh)
fi

# Helmfile
if command -v helmfile &> /dev/null; then
  source <(helmfile completion zsh)
fi

# ory
if command -v ory &> /dev/null; then
  source <(ory completion zsh)
fi

# pnpm
if command -v pnpm &> /dev/null; then
  source <(pnpm completion zsh)
fi

# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Starship
# https://starship.rs
export STARSHIP_CONFIG=${STARSHIP_CONFIG:-$ZDOTDIR/starship.toml}
eval "$(starship init zsh)"
