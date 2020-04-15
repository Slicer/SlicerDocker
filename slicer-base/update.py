#!/usr/bin/env python

import argparse
import os
import subprocess

#
# Usage:
#
#   $ ./update.py git_sha git_sha_date
#
# Example:
#
#   $ ./update.py b727d9a09 2020-04-14
#

def update_dockerfile(dockerfile, git_sha, git_sha_date):
    lines = []
    with open(dockerfile) as f:
        for line in f:
            if 'ENV SLICER_VERSION' in line:
                current_git_sha = line.strip().split(' ')[2]
                if current_git_sha == git_sha:
                    return False
                line = "ENV SLICER_VERSION %s\n" % git_sha
            if '# Slicer master ' in line:
                line = "# Slicer master %s\n" % git_sha_date
            lines.append(line)
    with open(dockerfile, 'w') as f:
        f.writelines(lines)
        print("File %s updated\n" % dockerfile)
    return True

def _run(cmd):
    print("Executing %s" % ' '.join(cmd))
    subprocess.check_call(cmd)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Update "slicer-base/Dockerfile" and git commit.')
    parser.add_argument("git_sha")
    parser.add_argument("git_sha_date")
    args = parser.parse_args()

    slicer_build_base_dir = os.path.dirname(__file__)
    dockerfile = os.path.join(slicer_build_base_dir, "Dockerfile")

    if update_dockerfile(dockerfile, args.git_sha, args.git_sha_date):
      _run(['git', 'add', dockerfile])
      message = 'ENH: slicer-base: Update to Slicer/Slicer@%s from %s' % (args.git_sha, args.git_sha_date)
      _run(['git', 'commit', '-m', message])
    else:
      print('"slicer-base/Dockerfile" already updated')

