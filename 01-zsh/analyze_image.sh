#!/bin/bash

analyze_oci_image() {
  local image=""
  local kubeconfig_path=""
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      --kubeconfig)
        kubeconfig_path="$2"
        shift 2
        ;;
      *)
        if [[ -z "$image" ]]; then
          image="$1"
        fi
        shift
        ;;
    esac
  done
  
  if [[ -z "$image" || -z "$kubeconfig_path" ]]; then
    echo "Usage: analyze_oci_image <image> --kubeconfig <path>"
    echo "   or: analyze_oci_image --kubeconfig <path> <image>"
    return 1
  fi
  
  if [[ ! -f "$kubeconfig_path" ]]; then
    echo "Error: kubeconfig file not found: $kubeconfig_path"
    return 1
  fi
  
  export KUBECONFIG="$kubeconfig_path"
  
  local oci_image="${image#oci://}"
  
  echo "Analyzing image: $oci_image"
  echo ""
  
  local manifest=$(oras manifest fetch "$oci_image" 2>/dev/null)
  
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch manifest"
    return 1
  fi
  
  local media_type=$(echo "$manifest" | jq -r '.config.mediaType // .mediaType // "Unknown"')
  local digest=$(oras manifest fetch "$oci_image" --descriptor 2>/dev/null | jq -r '.digest // "Unknown"')
  
  echo "Media Type: $media_type"
  echo "Digest: $digest"
  
  if [[ "$media_type" == "application/vnd.oci.image.config.v1+json" ]]; then
    echo "Tool: Using skopeo for container image"
    local skopeo_url="docker://oci.${oci_image#oci.}"
    local inspect_output=$(skopeo inspect "$skopeo_url" 2>/dev/null)
    local build_date=$(echo "$inspect_output" | jq -r '.Created // .Labels["org.opencontainers.image.created"] // "Not set in image"')
    echo "Build Date: $build_date"
  else
    echo "Tool: Using oras for OCI artifact"
    local build_date=$(echo "$manifest" | jq -r '.annotations."org.opencontainers.image.created" // "Not set in artifact"')
    echo "Build Date: $build_date"
  fi
}
