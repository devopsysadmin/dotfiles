#!/bin/bash -x
WORKSPACE_DIR=$HOME/.config/workspaces
TMP="/tmp/$(date +workspace.%s)"

workspace_usage(){
	echo '
	Enables|Disables python+ruby+node versions for a given workspace

	Usage: workspace ACTION WORKSPACE
	ACTION - enable|disable|create|edit
	WORKSPACE - name of the workspace to run
	'
}

workspace_enable(){
	echo '#!/bin/bash +x' > $TMP
	source $WORKSPACE_DIR/$1
	[[ -z $PYTHON ]] || workspace_enable_python $PYTHON $1
	[[ -z $RUBY ]] || workspace_enable_ruby $RUBY
	if [ $NODE ] || [ $NPM ]; then
		workspace_enable_nvm
		[[ -z $NODE ]] || workspace_enable_node $NODE
		[[ -z $NPM ]] || workspace_enable_npm $NPM
	fi
	echo 'rm -f $0' >> $TMP
}

workspace_enable_python(){
	local _pyver=$(which python$1)
	local _ws=$2
	for VE in \
	  $HOME/.local/bin/virtualenvwrapper.sh \
	  /usr/bin/virtualenvwrapper.sh \
	  /usr/local/bin/virtualenvwrapper.sh \
	;do
	  [[ -f $VE ]] && echo "source $VE" >> $TMP && break
	done
	echo "workon $_ws || mkvirtualenv -p $_pyver $_ws" >> $TMP
}

workspace_enable_nvm(){
    for NVM in \
		$HOME/.local/share/nvm/nvm.sh \
		/usr/share/nvm/init-nvm.sh \
		/usr/local/opt/nvm/nvm.sh \
    ;do
        [[ -f $NVM ]] && echo "source $NVM" >> $TMP && break
    done
}

workspace_enable_node(){
	echo "nvm use $1" >> $TMP
}

workspace_enable_npm(){
	echo "npm_current=\$(npm -v)" >> $TMP
	echo "[[ \$npm_current != '$1' ]] && npm install -g npm@$1" >> $TMP
}

workspace_enable_ruby(){
	for RVM in \
		$HOME/.local/share/rvm/scripts/rvm \
		/usr/share/rvm/scripts/rvm /etc/profile.d/rvm.sh \
	;do
		[[ -f $RVM ]] && echo "source $RVM" >> $TMP && break
	done
	echo "rvm use $1 || (rvm install $1 && rvm use $1)" >> $TMP
}

workspace_disable(){
	return 0
}

workspace_input(){
	local _question=$1
	local _defaults=$2
	[[ -z $_defaults ]] || _question+=" ($_defaults)"
	_question+='? '
	>&2 echo -n "$_question"
	read OPTION
	[[ -n $_defaults ]] && [[ -z $OPTION ]] && OPTION=$_defaults
	echo $OPTION
}

workspace_create(){
	local fn="$WORKSPACE_DIR/$1"
	[[ -f $fn ]] && source $fn
	PYTHON=$(workspace_input 'Python' $PYTHON)
	RUBY=$(workspace_input 'Ruby' $RUBY)
	NODE=$(workspace_input 'Node' $NODE)
	NPM=$(workspace_input 'Npm' $NPM)
	echo '' > $fn
	echo "PYTHON=$PYTHON" >> $fn
	echo "RUBY=$RUBY" >> $fn
	echo "NODE=$NODE" >> $fn
	echo "NPM=$NPM" >> $fn
	>&2 echo -n "Enable now (y/N)?" ; read ENABLE
	([[ $ENABLE == 'y' ]] || [[ $ENABLE == 'Y' ]]) && workspace_enable $1
}

workspace_search(){
	[[ -f $WORKSPACE_DIR/$1 ]] || return 1
}

ACTION=$1
WORKSPACE=$2

case $ACTION in
	enable)
		if workspace_search $WORKSPACE; then
			workspace_enable $WORKSPACE
			echo $TMP
		else
			>&2 echo "$WORKSPACE not found in $WORKSPACE_DIR"
			exit 1
		fi
		;;
	disable)
		if workspace_search $WORKSPACE; then
			workspace_disable $WORKSPACE
			echo $TMP
		else
			>&2 echo "$WORKSPACE not found in $WORKSPACE_DIR"
			exit 1
		fi
		;;
	create) workspace_create $WORKSPACE ;;
	edit) workspace_create $WORKSPACE ;;
	help) workspace_help && exit 0 ;;
	*) workspace_help && exit 1 ;;
esac
