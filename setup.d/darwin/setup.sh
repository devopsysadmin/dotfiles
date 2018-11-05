#!/bin/bash
SETUP_DIR=${SETUP_DIR:-${PWD%'/darwin'}}
source $SETUP_DIR/functions.inc.sh
###########

YesNo "Install Utilities" N && brew install \
	coreutils
