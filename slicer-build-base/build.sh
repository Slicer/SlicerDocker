#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker build -t slicer/slicer-build-base $script_dir
