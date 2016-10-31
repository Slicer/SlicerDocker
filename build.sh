#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

$script_dir/slicer-base/build.sh && \
$script_dir/slicer-dependencies/build.sh && \
$script_dir/slicer-build/build.sh && \
$script_dir/slicer-test/build.sh && \
$script_dir/slicer-test/opengl/build.sh

