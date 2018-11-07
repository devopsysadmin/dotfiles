#!/bin/bash
SETUP_DIR=${SETUP_DIR:-${PWD%'/darwin'}}
source $SETUP_DIR/functions.inc.sh
TMP=/tmp/$(whoami).setup
###########

BackupProfile(){
	for fn in .bash_profile .zshrc
	do
		cp $HOME/$fn $TMP/$fn
	done
}

RestoreProfile(){
	mv $TMP/.* $HOME/
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


######## MAIN
mkdir -p $TMP
YesNo "Install rvm" N && InstallRvm
YesNo "Install nvm" N && InstallNvm
YesNo "Install Utilities" N && $SETUP_DIR/darwin/packages.sh
rm -fR $TMP