#!/bin/bash

source $DOTDIR/src/*

declare -A _keys 
_keys["device__id_rsa"]="7c426c37-1d2f-4b4c-a1a1-b342015d1df1"
_keys["im_rsa"]="98d8587d-510c-4223-b2f7-b342015cc8c2"


_config="dc5f0c94-7f23-4e6e-9ed8-b3420161096d"

_dst="$HOME/.ssh"

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

if [ -f "$_dst/config" ]; then 
    __info "ssh configs already exist. Skipping..."
else 
    __info "retrieving ssh configs"
    bw list items --search 'ssh config' | jq '.[].notes' | sed 's/\\n/\n/g' | sed 's/\\t/    /g' | sed 's/"//g' > $_dst/config 
fi
