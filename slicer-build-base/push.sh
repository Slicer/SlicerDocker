#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker push slicer/$(basename $script_dir)
