#!/bin/bash

source ./src/*

export DOTDIR=$HOME/dots
export CONFIG_DIR=$HOME/.config

__title "Updating APT stores"
sudo apt update

__bitwarden() {
    __title "Checking for Bitwarden"
    if ! command -v bw; then
        __info "Bitwarden CLI not found. Installing now..."
        sudo apt install jq unzip
        wget https://github.com/bitwarden/clients/releases/download/cli-v2025.8.0/bw-linux-2025.8.0.zip
        unzip bw-linux-2025.8.0.zip
        mv bw $HOME/.local/bin/bw
    else 
        __info "Bitwarden CLI found at $(which bw)"
    fi
    export BW_SESSION=$(bw login --raw)
}

__main() {
    __title "Installing Dependencies and Setting Configurations"
    for script in ./scripts/*; do
        __warn "Running script $script"
        bash $script
    done

    for file in *; do
    	if [ -d $file ]; then
            tgt="${file:3}"
            # if [ -f $file/install.sh ]; then 
            #     bash $file/install.sh
            # else 
            #     __debug "  ==> no further installation required for $file"
            # fi

    		if [ -L  $CONFIG_DIR/$tgt ]; then
    			__info "Link for configs [$tgt] already set"
            elif [ $file == "scripts" ]; then
                __info "skipping additional install scripts"
            elif [ $file == "src" ]; then 
                __info "skipping helper scripts"
    		else 
                __info "$CONFIG_DIR/$tgt doesnt exist"
                ln -s $DOTDIR/$file $CONFIG_DIR/$tgt
    			__info "Created link for configs [$tgt]"
    		fi
    	fi
    done
}

__bitwarden
__main
