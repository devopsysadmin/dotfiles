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

git_pull_upstream(){
    local _branch="$1"
    git branch --set-upstream-to="origin/$_branch" "$_branch" ; git pull
}

git_fetch_prune_local(){ git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -d ;}

git_commit_dirty(){ git add -A . && git commit -m "_$(date +%Y%m%d_%H%M%S)" && git push ;}

git_push_force(){ git push --force ;}	

BRANCH="$(git_current_branch)"
case $(basename $0) in
    gbc) echo "$BRANCH" ;;
    gps) git push --set-upstream origin "$BRANCH" ;;
    gl) git pull $@ ;;
    gls) git_pull_upstream "$BRANCH" ;;
    git-clean-conflict) find . -name "*_BACKUP_*" -o -name "*_LOCAL_*" -o -name "*_BASE_*" -o -name "*_REMOTE_*" | xargs rm ;;
    gco) git checkout $@ ;;
    gfp) git_fetch_prune_local ;;
	gcd) git_commit_dirty ;;
	gpf) git_push_force ;;
esac
