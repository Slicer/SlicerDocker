#!/bin/sh

docker run -p 8888:8888 -p49053:49053 -v "$PWD":/home/sliceruser/work --rm -ti slicer/slicer-notebook
