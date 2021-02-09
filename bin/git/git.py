#!/usr/bin/env python3
## Some git calls are symlinks to this file
## because regex-oriented tasks are easier

import subprocess
import re
from sys import argv, exit
import os

def get_current_branch(args):
    RE_CURRENT_BRANCH = re.compile(
        r"^[*]"       # Leading "*" denotes the current branch from "git branch" 
        "\s{1}"       # Single space after "*"
        "(.*)",       # Group 1: current branch name 
        re.MULTILINE
    )
    out = subprocess.run(["git", "branch"], capture_output=True, text=True)
    current_branch_full_match = re.search(RE_CURRENT_BRANCH, out.stdout)
    current_branch = current_branch_full_match.group(1)
    if not args:
        print(current_branch)
    return current_branch


def _git_commit(message):
    subprocess.run(['git', 'commit', '-am', f"{message}"])


def gci(args):
    current_branch_slugs = get_current_branch(True).split('/')
    brackets = 'NO-ISSUE'
    if len(current_branch_slugs) > 1:
        issue_id = re.search('(\w+)-(\d+)', current_branch_slugs[1])
        if issue_id:
            brackets = issue_id.group(1)
    _git_commit(f"[{brackets}] {' '.join(args)}")


def main():
    func = os.path.basename(argv[0])
    args = argv[1:]
    func_dict = {
        'git-current-branch': get_current_branch
    }
    if func in func_dict:
        func_dict[func](args)
    elif func in globals():
        globals()[func](args)
    else:
        exit(f"what the hell is '{func}'?")


if __name__ == '__main__':
    main()
