#!/usr/bin/env python3
from argparse import ArgumentParser
from configparser import ConfigParser
import os
from subprocess import call
import sys

config = ConfigParser()


def get_args():
    parser = ArgumentParser()
    parser.add_argument('-p', '--pull-request', dest='pullrequest', action='store_true')
    parser.add_argument('-i', '--install', action='store_true')
    return parser.parse_args()

def get_branch():
    with open('.git/HEAD', 'r') as fn:
        ref = fn.read()
    return ref.strip().replace('ref: refs/heads/', '')


def get_url():
    gitconfig = '.git/config'
    new_url = '{schema}//{url}/{context}/projects/{project}/repos/{repo}'
    if os.path.exists(gitconfig):
        with open(gitconfig, 'r') as fn:
            config.read(gitconfig)
    (schema, url, context, project, repo) = config.get('remote "origin"', 'url'
                                            ).replace(':7999', '/bitbucket'
                                            ).replace('ssh://git@', 'https:/'
                                            ).replace('.git', ''
                                            ).split('/')
    return new_url.format(
                        schema = schema,
                        url = url,
                        context = context,
                        project = project.upper(),
                        repo = repo
            )

def open_browser(pullrequest):
    url = get_url()
    branch = get_branch()
    if(pullrequest):
        url += '/pull-requests?create&sourceBranch=refs/heads/%s' %branch
    else:
        if branch : url += '/browse?at=%s' %branch
    call(['open', url])


def install_alias():
    cmd = [ 'git', 'config', '--global', 'alias.browse', '!%s' %sys.argv[0] ]
    call(cmd)


def main(args):
    if args.install:
        install_alias()
    else:
        open_browser(args.pullrequest)


if __name__ == '__main__':
    args = get_args()
    main(args)
