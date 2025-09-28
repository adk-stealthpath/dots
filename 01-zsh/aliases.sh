#!/usr/bin/zsh
# useful aliases
alias v="nvim"
alias t="tmux"
alias sudo="sudo --preserve-env"
alias k9s="k9s"
# alias docker="podman"
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
    man_dir="/opt/helmet/.kube/k0s/merged.yaml"
    context=$(kubectl --kubeconfig $man_dir config get-contexts | awk '{print $2}' | sed -n '2 p')
    k9s --kubeconfig $man_dir --context $context --command contexts --headless
}

alias ks="load_k9s"
alias kl="k9s --kubeconfig ~/.kube/config"

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

# alias schwartz-argo='export -f kubectl; find $HOME/stealthpath/schwartz/argo-workflow-templates -path "*/archive" -prune -o -type f -name "*.yaml" -print0 | xargs -0 -I{} bash -c '\''CONTENT=$(sed "s|__SUBJECT_CN__|schwartz.spc.sp|g" "{}"); if [ -n "$CONTENT" ]; then echo "$CONTENT" | kubectl apply -f -; else echo "Skipping empty file: {}"; fi'\'''
schwartz_argo() {
   local __subject_cn="${1:-schwartz-ajn.spc.sp}"
   local kubectl_cmd="kubectl"

   if [ -n "$KUBE_CONTEXT" ]; then
       kubectl_cmd="kubectl --context=$KUBE_CONTEXT"
   fi

   export -f kubectl
   find ~/stealthpath/schwartz/argo-workflow-templates -path "*/archive" -prune -o -type f -name "*.yaml" -print0 | \
   xargs -0 -I{} bash -c '
       CONTENT=$(sed "s|__SUBJECT_CN__|'"$__subject_cn"'|g" "{}");
       if [ -n "$CONTENT" ]; then
           echo "$CONTENT" | '"$kubectl_cmd"' apply -f -;
       else
           echo "Skipping empty file: {}";
       fi'
}
alias upd_wf=schwartz_argo

kubectl() {
  # Run kubectl and store arguments
  local output_format_arg=false
  for arg in "$@"; do
    if [[ "$arg" == "-o" || "$arg" == --output=* || "$arg" == json || "$arg" == yaml || "$arg" == jsonpath=* ]]; then
      output_format_arg=true
      break
    fi
  done

  if [ "$output_format_arg" = true ]; then
    # Don't color structured output
    command kubectl "$@"
  else
    # Color normal output
    command kubectl "$@" | awk '
      {
        gsub(/created/,    "\033[0;32m&\033[0m")  # green
        gsub(/updated/,    "\033[0;33m&\033[0m")  # yellow
        gsub(/unchanged/,  "\033[0;90m&\033[0m")  # gray
        gsub(/deleted/,    "\033[0;31m&\033[0m")  # red
        gsub(/configured/, "\033[0;34m&\033[0m")  # blue
        print
      }'
  fi
}

alias k="kubectl"
