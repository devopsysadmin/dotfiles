#!/bin/bash -e
git_current_branch(){
    local ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return  # no git repo.
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    fi
    echo ${ref#refs/heads/}
}

git_commit_issue(){
    local _branch="$1" ; shift
    local _opts="$1" ; shift
    local _message="$@"
    local ISSUE=$(echo "$_branch" |\
        sed -e 's/^feature\///g' -e 's/develop-//g' |\
        sed -n 's/\(.*-[0-9]*\)-.*/\1/p')
    if [[ $_opts =~ ^-.* ]]; then
        echo -n ''
    else
        _message="$_opts"
        _opts="-am"
    fi
    git commit $_opts "[$ISSUE] $_message"
}

git_pull_upstream(){
    local _branch="$1"
    git branch --set-upstream-to="origin/$_branch" "$_branch" ; git pull
}

git_branch_delete(){
    local _branch="$1"
    git branch -D "${_branch}" && git push origin :"${_branch}"
}

git_fetch_prune_local(){
    git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -d
}

BRANCH="$(git_current_branch)"
case $(basename $0) in
    gbc) echo "$BRANCH" ;;
    gbd) git_branch_delete "$1" ;;
    gps) git push --set-upstream origin "$BRANCH" ;;
    gl) git pull $@ ;;
    gls) git_pull_upstream "$BRANCH" ;;
    git-clean-conflict) find . -name "*_BACKUP_*" -o -name "*_LOCAL_*" -o -name "*_BASE_*" -o -name "*_REMOTE_*" | xargs rm ;;
    gci) git_commit_issue "$BRANCH" "$@";;
    gco) git checkout $@ ;;
    gfp) git_fetch_prune_local ;;
esac
