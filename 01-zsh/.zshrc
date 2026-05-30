plugins=(git zsh-autosuggestions zsh-syntax-highlighting vi-mode)
ZSH_THEME=avit
# User configuration

# ensure ssh agent is runninng
# [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $HOME/.config/zsh/env.sh
source $HOME/.config/zsh/aliases.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Wayland display fallback for terminals spawned outside the compositor env
if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/wayland-1" ]; then
    export WAYLAND_DISPLAY=wayland-1
fi
