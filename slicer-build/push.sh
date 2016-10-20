#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker push slicer/slicer-build:BUILD_TESTING_ON
