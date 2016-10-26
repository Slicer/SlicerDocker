#!/usr/bin/env python

import argparse
import os
import subprocess

#
# Usage:
#
#   $ ./update.py svn_revision svn_revision_date
#
# Example:
#
#   $ ./update.py 25199 2016-06-19
#

def update_dockerfile(dockerfile, svn_revison, svn_revision_date):
    lines = []
    with open(dockerfile) as f:
        for line in f:
            if 'ENV SLICER_VERSION' in line:
                current_svn_revision = line.strip().split(' ')[2]
                if current_svn_revision == svn_revison:
                    return False
                line = "ENV SLICER_VERSION %s\n" % svn_revison
            if '# Slicer master ' in line:
                line = "# Slicer master %s\n" % svn_revision_date
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
    parser.add_argument("svn_revision")
    parser.add_argument("svn_revision_date")
    args = parser.parse_args()

    slicer_build_base_dir = os.path.dirname(__file__)
    dockerfile = os.path.join(slicer_build_base_dir, "Dockerfile")

    if update_dockerfile(dockerfile, args.svn_revision, args.svn_revision_date):
      _run(['git', 'add', dockerfile])
      message = 'ENH: slicer-base: Update to Slicer r%s from %s' % (args.svn_revision, args.svn_revision_date)
      _run(['git', 'commit', '-m', message])
    else:
      print('"slicer-base/Dockerfile" already updated')

