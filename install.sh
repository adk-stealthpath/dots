#!/bin/bash

export DOTDIR=$HOME/dots

for file in *; do
	if [ -d $file ]; then
		if [ -d $XDG_CONFIG_HOME/$file ]; then
			echo "Link for configs [$file] already set"
		else 
			ln -s $PWD/$file $XDG_CONFIG_HOME/$file
			echo "Created link for configs [$file]"
		fi

        if [ -f $file/install.sh ]; then 
            bash $file/install.sh
        else 
            echo "  ==> no further installation required for $file"
        fi
         
	else 
		echo "Skipping file [$file]"
	fi
done
