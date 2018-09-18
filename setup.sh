#!/bin/bash -e
## This script setups the routes and utilities given the current operating system.

CFG=$HOME/.config
BIN=$HOME/.local/bin
PLATFORM=
DISTRO=


Link(){ local _orig="$1" ; local _dest="$2" ; [[ -f $_orig ]] && ln -nfs "$_orig" "$_dest" || rm -f "$_dest" ;}

YesNo(){
	local _msg=$1
	local _default=${2:-'Y'}
	local _yes='y'
	local _no='n'
	[[ ${_default} == 'Y' ]] && _yes='Y'
	[[ ${_default} == 'N' ]] && _no='N'
	>&2 echo -n "$_msg (${_yes}/${_no})? " ; read OPT
	[[ -z $OPT ]] && OPT=${_default}
	if [ "$OPT" == 'Y' ] || [ "$OPT" == 'y' ]; then
		return 0
	else
		return 1
	fi
}

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


########## MAIN
SetPlatformDistro

## Directory structure
mkdir -p $BIN && ln -nfs $PWD/bin/os $BIN/os
mkdir -p $CFG && ln -nfs $PWD/config/shell $CFG/shell

## Shell
Link $CFG/shell/os/${PLATFORM}/aliases $CFG/shell/aliases_platform
[[ -z $DISTRO ]] || Link $CFG/shell/os/${DISTRO}/aliases $CFG/shell/aliases_distro

## Routes
SetRoutes

## Enable zshrc
echo 'source $HOME/.config/shell/zsh/zshrc' > $HOME/.zshrc
