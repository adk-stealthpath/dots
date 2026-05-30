#!/usr/bin/zsh

yogurt-env() {
  if [[ -z "$BW_SESSION" ]]; then
    echo "Bitwarden session not found. Unlocking..."
    export BW_SESSION=$(bw unlock --raw)
    if [[ $? -ne 0 ]]; then
      echo "Failed to unlock Bitwarden vault"
      return 1
    fi
  fi

  export FORGEJO_TOKEN=$(bw get password "forgejo-access-token")
  export HARBOR_ROBOT_SECRET=$(bw get password "harbor-access-token")
  export TRUENAS_API_KEY=$(bw get password "truenas-access-token")
  export PROXMOX_TOKEN_ID=$(bw get username "proxmox-access-token")
  export PROXMOX_TOKEN_SECRET=$(bw get password "proxmox-access-token")

  local missing=0
  for var in FORGEJO_TOKEN HARBOR_ROBOT_SECRET TRUENAS_API_KEY PROXMOX_TOKEN_ID PROXMOX_TOKEN_SECRET; do
    if [[ -z "${(P)var}" ]]; then
      echo "✗ $var — failed to load"
      missing=$((missing + 1))
    else
      echo "✓ $var"
    fi
  done

  if [[ $missing -gt 0 ]]; then
    echo "$missing variable(s) failed to load"
    return 1
  fi

  echo "\nyogurt environment ready"
}

