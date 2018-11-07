#!/bin/bash
WORKSPACE_DIR=$HOME/.config/workspaces
TMP="/tmp/$(date +workspace.%s)"

PYTHON_DEFAULT=3

Workspace.usage(){
    >&2 echo '
    Enables|Disables python+ruby+node versions for a given workspace

    Usage: workspace ACTION WORKSPACE
    ACTION - enable|disable|create|edit|delete
    WORKSPACE - name of the workspace to run
    '
}

Workspace.enable(){
    echo '#!/bin/bash' > $TMP
    source $WORKSPACE_DIR/$WORKSPACE
    echo "WORKSPACE=$WORKSPACE" >> $TMP
    echo "source $PYTHON_SCRIPT" >> $TMP
    echo "source $RUBY_SCRIPT" >> $TMP
    echo "source $NODE_SCRIPT" >> $TMP
    [[ -z $PYTHON ]] && PYTHON=3 ; Python.enable $PYTHON $1 >> $TMP
    [[ -z $RUBY ]] || Ruby.enable $RUBY >> $TMP
    if [ $NODE ] || [ $NPM ]; then Node.enable $NODE $NPM >> $TMP; fi
    echo 'rm -f $0' >> $TMP
}

Python.find(){
    for VE in \
        $HOME/.local/bin/virtualenvwrapper.sh \
        /usr/bin/virtualenvwrapper.sh \
        /usr/local/bin/virtualenvwrapper.sh \
    ;do
        [[ -f $VE ]] && echo "$VE" && break
    done
}

Python.enable(){
	local _pyver=$1
    local _pybin=$(which python$_pyver)
    local _ws=$2
    echo "echo Using python$_pyver in $_ws virtualenv"
    echo "workon $_ws || mkvirtualenv -p $_pybin $_ws"
}

Python.disable(){
    echo "deactivate"
}

Python.delete(){
	local _ws=$1
    echo "rm -fR $WORKON_HOME/$_ws" >> $TMP
}

Node.find(){
    for NVM in \
        $HOME/.local/share/nvm/nvm.sh \
        /usr/share/nvm/init-nvm.sh \
        /usr/local/opt/nvm/nvm.sh \
    ;do
        [[ -f $NVM ]] && echo "$NVM" && break
    done
}

Node.enable(){
    local _node=$1
    local _npm=$2
    echo "nvm use v$_node
    npm_current=\$(npm -v)
    [[ \$npm_current != '$_npm' ]] && npm install -g npm@$_npm"
}

Node.disable(){
    echo "nvm use default"
}

Ruby.find(){
    for RVM in \
        $HOME/.local/share/rvm/scripts/rvm \
        /usr/share/rvm/scripts/rvm /etc/profile.d/rvm.sh \
    ;do
        [[ -f $RVM ]] && echo "$RVM" && break
    done
}

Ruby.enable(){
    echo "rvm use $1 || (rvm install $1 && rvm use $1)"
}

Ruby.disable(){
    echo "rvm use system"
}

Workspace.disable(){
    Node.disable >> $TMP
    Ruby.disable >> $TMP
    Python.disable >> $TMP
    echo "export WORKSPACE=" >> $TMP
}

Workspace.input(){
    local _question=$1
    local _defaults=$2
    [[ -z $_defaults ]] || _question+=" ($_defaults)"
    _question+='? '
    >&2 echo -n "$_question"
    read OPTION
    [[ -n $_defaults ]] && [[ -z $OPTION ]] && OPTION=$_defaults
    echo $OPTION
}

Workspace.create(){
    local fn="$WORKSPACE_DIR/$WORKSPACE"
    [[ -f $fn ]] && source $fn
    PYTHON=$(Workspace.input "Python (default $PYTHON_DEFAULT)" $PYTHON) ; [[ -z $PYTHON ]] && PYTHON=$PYTHON_DEFAULT
    RUBY=$(Workspace.input 'Ruby' $RUBY)
    NODE=$(Workspace.input 'Node' $NODE)
    NPM=$(Workspace.input 'Npm' $NPM)
    echo "WORKSPACE=$WORKSPACE" > $fn
    echo "PYTHON_SCRIPT=$(Python.find)" >> $fn
    echo "RUBY_SCRIPT=$(Ruby.find)" >> $fn
    echo "NODE_SCRIPT=$(Node.find)" >> $fn
    echo "PYTHON=$PYTHON" >> $fn
    echo "RUBY=$RUBY" >> $fn
    echo "NODE=$NODE" >> $fn
    echo "NPM=$NPM" >> $fn
}

Workspace.search(){
    [[ -f $WORKSPACE_DIR/$1 ]] || return 1
}

Workspace.delete(){
	local _ws=$1
    Python.delete $_ws
    rm $WORKSPACE_DIR/$_ws
}

Workspace.list(){
	ls -1 $WORKSPACE_DIR
}

ACTION=$1
WORKSPACE=${2:-$WORKSPACE}
[[ -z $WORKSPACE ]] && WORKSPACE=$(basename ${VIRTUAL_ENV} 2>/dev/null)

case $ACTION in
    enable)
        if Workspace.search $WORKSPACE; then
            Workspace.enable $WORKSPACE
            export $WORKSPACE
            echo $TMP
        else
            >&2 echo "$WORKSPACE not found in $WORKSPACE_DIR"
            exit 1
        fi
        ;;
    disable)
        if Workspace.search $WORKSPACE; then
            Workspace.disable $WORKSPACE
            echo $TMP
        else
            >&2 echo "$WORKSPACE not found in $WORKSPACE_DIR"
            exit 1
        fi
        ;;
    create) Workspace.create $WORKSPACE ;;
    edit) Workspace.create $WORKSPACE ;;
    show) >&2 cat $WORKSPACE_DIR/$WORKSPACE ;;
    delete) Workspace.delete $WORKSPACE ; echo $TMP ;;
    help) Workspace.usage && exit 0 ;;
	list) >&2 Workspace.list ;;
    *) Workspace.usage && exit 1 ;;
esac
