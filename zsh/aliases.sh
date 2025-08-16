#!/usr/bin/zsh
# useful aliases
alias v="nvim"
alias tmux="tmux -u2"
alias sudo="sudo --preserve-env=PATH"
alias k9s="k9s"
# alias docker="podman"
alias k="kubectl"
alias p="podman"
alias C="xclip -selection clipboard"
alias V="xclip -o -selection clipboard"
alias bat="batcat"
# alias cat="bat"

ksloc() {
    kubectl --context spaceball-one-nightly get secret -n zcollect $1 -o jsonpath="{.data.$2}" | base64 -d - | cut -d' ' -f1
}

source $ZSH_CUSTOM/oh-my-zsh.sh
source $ZDOTDIR/kubectl.autocomplete
#
# zoxide key bindings 
eval "$(zoxide init zsh --cmd cd)"

unalias l
alias l="eza --time-style=long-iso -al --changed"
unalias ll
alias ll="eza --time-style=long-iso -l --changed"

# k9s proper loading 
load_k9s() {
    context=$(kubectl config get-contexts | awk '{print $2}' | sed -n '2 p')
    k9s --kubeconfig $HOME/.kube/k0s/config.yaml --context $context --command contexts
}

alias kl="load_k9s"

alias bc=build

build() {
    domain=$1
    if [[ -z $domain ]]; then
        domain="zot.adk"
    fi
    TAG=$domain.stealthpathdev.com/images/$(basename `pwd`):latest
    echo "=====> TAG=$TAG <====="
    echo ""
    podman build -t $TAG -f Dockerfile ~/stealthpath/zcore
    podman push $TAG
}

k0sz_config() {
  if [ -z "$1" ]; then
    echo "Usage: k0s_config <last_octet_of_ip>"
    return 1
  fi

  IP="10.10.0.$1"
  ssh -q sandurz@$IP sudo k0s kubeconfig admin > ~/.kube/sandurz.yaml
  if [ $? -eq 0 ]; then
    echo "Kubeconfig written to ~/.kube/sandurz.yaml"
  else
    echo "Failed to generate kubeconfig from $IP"
  fi
}

alias "k9sz"="~/go/bin/k9s --kubeconfig ~/.kube/sandurz.yaml"

alias schwartz-argo='export -f kubectl; find $HOME/stealthpath/schwartz/argo-workflow-templates -path "*/archive" -prune -o -type f -name "*.yaml" -print0 | xargs -0 -I{} bash -c '\''CONTENT=$(sed "s|__SUBJECT_CN__|schwartz.spc.sp|g" "{}"); if [ -n "$CONTENT" ]; then echo "$CONTENT" | kubectl apply -f -; else echo "Skipping empty file: {}"; fi'\'''
