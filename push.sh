#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

$script_dir/slicer-base/push.sh && \
$script_dir/slicer-dependencies/push.sh && \
$script_dir/slicer-build/push.sh && \
$script_dir/slicer-test/push.sh
