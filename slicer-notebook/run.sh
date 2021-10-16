#!/bin/bash

set -ex

script_dir=$(cd $(dirname $0) || exit 1; pwd)

################################################################################
# Set up headless environment
source $script_dir/start-xorg.sh

#/usr/bin/x11vnc -forever -rfbport $VNCPORT -display :10 -shared -bg -auth none -nopw
#sleep 1

################################################################################
# start window manager

# Do not start a window manager to make the remote desktop look more like a simple
# remote view rather than a complete remote computer.
#awesome &

################################################################################
# Set jupyter terminal to bash (better auto-complete, etc. than default sh)

export SHELL=/bin/bash

################################################################################
# this needs to be last
exec "$@"
