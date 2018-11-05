#!/bin/bash -e
## This script setups the routes and utilities given the current operating system.
export SETUP_DIR=$PWD/setup.d

CFG=$HOME/.config
BIN=$HOME/.local/bin
PLATFORM=
DISTRO=
source $SETUP_DIR/functions.inc.sh

SetPlatformDistro(){
	PLATFORM=$(python -m platform | cut -d "-" -f 1 | tr -s '[:upper:]' '[:lower:]')
	if [ "$PLATFORM" == "linux" ]; then
		if [ -f /etc/os-release ]; then
		    local ID=$(egrep '^ID=' /etc/os-release | cut -d "=" -f2)
		fi
  		case $ID in
    		neon|ubuntu|debian) DISTRO=debian ;;
    		manjaro|arch) DISTRO=arch ;;
  		esac
	fi
}

SetRoutes(){
	local RPATH='$HOME/.local/bin:$HOME/.local/bin/git:$HOME/.local/bin/'${PLATFORM}
	local SPATH='/usr/local/bin:/usr/local/sbin'
	if [ -z $DISTRO ]; then
		echo "export PATH=$RPATH:$SPATH:\$PATH" > $CFG/shell/01_routes
	else
		DLPATH='$HOME/.local/bin/'${DISTRO}
		echo "export PATH=$RPATH:$DLPATH:$SPATH:\$PATH" > $CFG/shell/01_routes
	fi
}

Zsh(){
	echo -n "Getting/Updating oh-my-zsh... "
	Link $PWD/config/shell/zsh $CFG/shell/zsh
	if [ -d $CFG/shell/zsh/oh-my-zsh ]; then
		git -C $CFG/shell/zsh/oh-my-zsh pull
	else
		git -C $CFG/shell/zsh clone https://github.com/robbyrussell/oh-my-zsh
	fi
	Link $PWD/config/shell/zsh/owntheme.zsh-theme $CFG/shell/zsh/oh-my-zsh/themes/owntheme.zsh-theme
}

OsConfigLinks(){
	for _custom in $CFG/shell/os/${PLATFORM}/*; do
		_name=$(basename ${_custom})
		Link ${_custom} ${CFG}/shell/${_name}_platform
	done

	if [ ! -z $DISTRO ]; then
		for _custom in $CFG/shell/os/${PLATFORM}/${DISTRO}/*; do
			_name=$(basename ${_custom})
			Link ${_custom} ${CFG}/shell/${_name}_platform_distro
		done
	fi
}

RecurseLink(){
	local _source_dir="$1"
	local _dest_dir="$2"
	for binary in $_source_dir/*; do [[ -f $binary ]] && Link $binary $_dest_dir/$(basename $binary); done
}

OsBinLinks(){
	RecurseLink $PWD/bin $BIN
	RecurseLink $PWD/bin/os/$PLATFORM $BIN
	[[ -z $DISTRO ]] || RecurseLink $PWD/bin/os/$PLATFORM/$DISTRO $BIN
	Link $PWD/bin/git $BIN/git
}


########## MAIN
SetPlatformDistro

## Download Utilities
${SETUP_DIR}/${PLATFORM}/setup.sh

## Directory structure
mkdir -p $BIN && Link $PWD/bin/os $BIN/os
mkdir -p $CFG/shell/zsh && rsync --exclude=zsh -aH $PWD/config/shell/ $CFG/shell/
Link $PWD/config/shell/os $CFG/shell/os


## Shell
OsConfigLinks
OsBinLinks

## Routes
SetRoutes


## Download oh-my-zsh
Zsh

## Enable zshrc
cat << EOF > $HOME/.zshrc
export OS=$PLATFORM
export FLAVOUR=$DISTRO
source \$HOME/.config/shell/zsh/zshrc
EOF