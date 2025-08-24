#!/bin/bash

source $DOTDIR/src/*

declare -A _accts
_accts["default"]="b0a18924-1716-4cd9-bb13-af9c01436f16"
_accts["root"]="b0a18924-1716-4cd9-bb13-af9c01436f16"
_accts["eagle5"]="f6e7d6e6-b1cd-496a-996e-b02301042c5d"
_accts["devsecops"]="87dc4626-bcfe-4214-a5e3-af9c01436f16"

__info "Creating aws cli credentials file"
 
_dst="$HOME/aws-tmp"

if ! command -v aws; then
    __info "Installing aws cli v2"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    __info "Installed aws cli: $(aws --version)"
else
    __info "aws cli already installed: $(aws --version)"
fi 

if [ -f $_dst/credentials ]; then
    __info "Credentials file found. Skipping..."
else
    __info "Setting aws cli credentials file"
    mkdir -p $_dst
    touch $_dst/credentials
    touch $_dst/config
    
    for acct in "${!_accts[@]}"; do
        __debug "setting $acct credentials and configs"
        echo "[$acct]" >> $_dst/credentials
        _ak=$(bw get item "${_accts[$acct]}" | jq -r '.fields[] | select(.name == "access key").value')
        _sk=$(bw get item "${_accts[$acct]}" | jq -r '.fields[] | select(.name == "secret key").value') 
        echo "aws_access_key_id = $_ak" >> $_dst/credentials
        echo "aws_secret_access_key = $_sk" >> $_dst/credentials
        echo >> $_dst/credentials

        echo "[$acct]" >> $_dst/config
        echo "region = us-east-1" >> $_dst/config
        echo "output = json" >> $_dst/config
        echo >> $_dst/config
    done 
fi
