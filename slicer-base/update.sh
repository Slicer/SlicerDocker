#!/bin/bash

#
# Usage:
#
#  $ ./update.sh /path/to/src/Slicer
#
# Example:
#
#  $ ./update.sh ~/Projects/Slicer
#  slicer_dir:/home/jcfr/Projects/Slicer
#  svn_revision: 25199
#  svn_revision_date: 2016-06-19
#
#  File /home/jcfr/Projects/SlicerDocker/slicer-base/Dockerfile updated
#
#  Executing git add /home/jcfr/Projects/SlicerDocker/slicer-base/Dockerfile
#
#  Executing git commit -m ENH: slicer-base: Update to Slicer r25199 from 2016-06-19
#  [master 397eeab] ENH: slicer-base: Update to Slicer r25199 from 2016-06-19
#   1 file changed, 2 insertions(+), 2 deletions(-)
#

set -e

script_dir="`cd $(dirname $0); pwd`"

if test -z "$1"; then
  echo "Usage: $0 /path/to/src/Slicer"
  exit 1
fi

slicer_dir=$1

echo "slicer_dir:$slicer_dir"

pushd $slicer_dir > /dev/null 2>&1

git_sha=$(git log -1 --format="%h")
echo "git_sha: $git_sha"

git_sha_date=$(git log -1 --date=format:"%Y-%m-%d" --format="%cd")
echo "git_sha_date: $git_sha_date"

popd > /dev/null 2>&1
echo ""

python $script_dir/update.py $git_sha $git_sha_date

