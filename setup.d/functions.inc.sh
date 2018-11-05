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

Link(){
	local _orig="$1"
	local _dest="$2"
	if [ -f $_orig ] || [ -d $_orig ]; then
		rm -fR "${_dest}"
	fi
	ln -s "${_orig}" "${_dest}"
}
