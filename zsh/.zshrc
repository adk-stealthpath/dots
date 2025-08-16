plugins=(git zsh-autosuggestions zsh-syntax-highlighting vi-mode)
ZSH_THEME=avit
# User configuration

# ensure ssh agent is runninng
[ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $HOME/.config/zsh/env.sh
source $HOME/.config/zsh/aliases.sh
