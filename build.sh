#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

$script_dir/slicer-build-base/build.sh && \
$script_dir/slicer-dependencies/build.sh && \
$script_dir/slicer-build/build.sh

