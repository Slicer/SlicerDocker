#!/bin/sh

set -e
set +x

Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./10.log -config $HOME/xorg.conf $DISPLAY &

# grab the process id in order to control it later
export XORG_PID=$!

# give bg X time to start
sleep 2
