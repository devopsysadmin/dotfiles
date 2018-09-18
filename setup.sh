#!/bin/bash -xe
## This script setups the routes given the current operating system.

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


########## MAIN
SetPlatformDistro

## Shell
Link $CFG/shell/os/${PLATFORM}/aliases $CFG/shell/aliases_platform
[[ -z $DISTRO ]] || Link $CFG/shell/os/${DISTRO}/aliases $CFG/shell/aliases_distro

## Routes
ln -nfs $CFG/shell/os/${PLATFORM}/01_routes $CFG/shell/01_routes_platform
[[ -z $DISTRO ]] || Link $CFG/shell/os/${DISTRO}/01_routes $CFG/shell/01_routes_distro

