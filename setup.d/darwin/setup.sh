#!/bin/bash
SETUP_DIR=${SETUP_DIR:-${PWD%'/darwin'}}
source $SETUP_DIR/functions.inc.sh
TMP=/tmp/$(whoami).setup
PROFILES='.bash_profile .zshrc .profile .zlogin .mkshrc'
###########

BackupProfile(){
	for fn in $PROFILES; do
		[[ -f $fn ]] && cp $HOME/$fn $TMP/$fn
	done
}

RestoreProfile(){
	for fn in $PROFILES; do
		if [ -f $fn ]; then
			mv $TMP/$fn $HOME/$fn
		else
			rm -f $HOME/$fn
		fi
	done
}

InstallRvm(){
	BackupProfile
	which gpg || brew install gpg
	gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable
	mkdir -p $HOME/.local/share/rvm
	mv $HOME/.rvm $HOME/.local/share/rvm
	ln -nfs $HOME/.bash_profile $HOME/.bashrc
	RestoreProfile
}

InstallNvm(){
	BackupProfile
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	RestoreProfile
}

InstallPython(){
	which python2 || brew install python2
	which python3 || brew install python3
	pip2 install virtualenvwrapper
	pip3 install virtualenvwrapper
}

InstallBrew(){
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}


######## MAIN
mkdir -p $TMP
YesNo "Install brew" N && InstallBrew
YesNo "Brew Install Utilities" N && $SETUP_DIR/darwin/packages.sh
YesNo "Install python (2,3)" N && InstallPython
YesNo "Install rvm" N && InstallRvm
YesNo "Install nvm" N && InstallNvm
rm -fR $TMP

mkdir -p ~/Library/KeyBindings
cp $SETUP_DIR/../config/tools/KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings
