#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker build -t slicer/slicer-test $script_dir
