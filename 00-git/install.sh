#!/bin/bash

declare -A _keys
_keys["github_rsa"]="d54df796-72c8-4a86-b094-b342015c5958"
_keys["github_signing"]="c9db485b-a990-4804-8997-b342015c9498"

_dst=$HOME/.ssh

mkdir -p $_dst
for key in "${!_keys[@]}"; do
    if [ -f $_dst/$key ]; then 
        __info "$_dst/$key already exists. Skipping..."
    else 
        __info "retrieving $key private key"
        __get_pem "${_keys[$key]}" $_dst/$key 
    fi

    if [ -f $_dst/$key.pub ]; then 
        __info "$_dst/$key.pub already exists. Skipping..."
    else 
        __info "retrieving $key public key"
        __get_pem "${_keys[$key]}" $_dst/$key.pub 1
    fi
done

if [ -f "$_dst/allowed_signers" ]; then 
    __info "commit allowed signers already exist. Skipping..."
else 
    __info "generating git commit allowed signers"
    echo "$(git config user.email) namespaces=\"git\" $(cat $_dst/github_signing.pub)" > $_dst/allowed_signers
fi
