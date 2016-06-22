#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

$script_dir/slicer-build-base/push.sh && \
$script_dir/slicer-build-deps/push.sh && \
$script_dir/slicer-build/push.sh
