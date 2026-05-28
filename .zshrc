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
