#!/bin/bash

set -e
set +x

script_dir=$(cd $(dirname $0) || exit 1; pwd)
PROG=$(basename $0)

err() { echo -e >&2 ERROR: $@\\n; }
die() { err $@; exit 1; }

if [ "$#" -ne 1 ]; then
  die "Usage: $PROG /path/to/Slicer-X.Y.Z-linux-amd64/Slicer"
fi

slicer_executable=$1

################################################################################
# Set up headless environment
source $script_dir/start-xorg.sh
echo "XORG_PID [$XORG_PID]"

################################################################################
# Get slicer revision
slicer_revision=$($slicer_executable --disable-modules -c "print(slicer.app.revision)" | head -n1)
echo "slicer_revision [$slicer_revision]"

# Lookup extension_id associated with SlicerJupyter
#extension_id=$(curl -s -X GET \
#  "https://slicer.kitware.com/midas3/api/json?method=midas.slicerpackages.extension.list&os=linux&arch=amd64&slicer_revision=$slicer_revision&search=SlicerJupyter" \
#  -H "accept: application/json" | jq ".data[0].extension_id")
#echo "extension_id [$extension_id]"

# Download and install the extension install
#$slicer_executable \
#  --disable-loadable-modules \
#  --disable-cli-modules \
#  --disable-scripted-loadable-modules \
#  -c "slicer.app.extensionsManagerModel().downloadAndInstallExtension('$extension_id')"

# Install the extension install
extension_archive=$(ls -1 $PWD/$slicer_revision-linux-amd64-SlicerJupyter-*)
echo "extension_archive [$extension_archive]"
$slicer_executable \
  --disable-loadable-modules \
  --disable-cli-modules \
  --disable-scripted-loadable-modules \
  -c "slicer.app.extensionsManagerModel().installExtension('$extension_archive')"

# Install kernel
$slicer_executable \
  --disable-cli-modules \
  --disable-scripted-loadable-modules \
  -c "slicer.modules.jupyterkernel.installSlicerKernel('/usr/local/bin/')"

# Fix ImportError: ...python3.6/site-packages/PIL/_imaging.cpython-36m-x86_64-linux-gnu.so: ELF load command address/offset not properly aligned
# by forcing reinstalling pillow (a properly maintained fork of PIL).
$slicer_executable \
  --disable-cli-modules \
  --disable-scripted-loadable-modules \
  -c "pip_install('--upgrade pillow --force-reinstall'); pip_install('ipywidgets pandas ipyevents ipycanvas')"

# Install packages needed by SlicerNotebookLib
$slicer_executable \
  --disable-cli-modules \
  --disable-scripted-loadable-modules \
  -c "pip_install('ipywidgets pandas ipyevents ipycanvas')"

################################################################################
# Shutdown headless environment
kill -9 $XORG_PID
rm /tmp/.X10-lock
