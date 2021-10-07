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
# Set up Slicer extensions

echo "Set default application settings"
# - use CPU volume rendering (it is better optimized for software rendering)
$slicer_executable -c '
slicer.app.settings().setValue("VolumeRendering/RenderingMethod","vtkMRMLCPURayCastVolumeRenderingDisplayNode")
slicer.app.settings().setValue("Markups/GlyphScale", 3)
slicer.app.settings().setValue("Markups/UseGlyphScale", True)
'

echo "Install SlicerJupyter extension"
$slicer_executable -c '
em = slicer.app.extensionsManagerModel()
extensionMetaData = em.retrieveExtensionMetadataByName("SlicerJupyter")
print(f"extensionMetaData: {extensionMetaData}")
if slicer.app.majorVersion*100+slicer.app.minorVersion < 413:
    # Slicer-4.11
    itemId = extensionMetaData["item_id"]
    url = f"{em.serverUrl().toString()}/download?items={itemId}"
    print(f"itemId: {itemId} url: {url}")
    extensionPackageFilename = f"{slicer.app.temporaryPath}/{itemId}"
    slicer.util.downloadFile(url, extensionPackageFilename)
else:
    # Slicer-4.13
    #itemId = extensionMetaData["_id"]
    itemId = "30304-linux-amd64-SlicerJupyter-gitb3fba2d-2021-03-21.tar.gz"
    url = "https://github.com/Slicer/SlicerJupyter/files/7305919/30304-linux-amd64-SlicerJupyter-gitb3fba2d-2021-03-21.tar.gz"
    print("Using bespoke build from {url} until https://github.com/Slicer/SlicerJupyter/issues/59 is fixed")
    extensionPackageFilename = f"{slicer.app.temporaryPath}/{itemId}"
    slicer.util.downloadFile(url, extensionPackageFilename)
em.installExtension(extensionPackageFilename)
'

echo "Install Jupyter server (in Slicer's Python environment) and Slicer Jupyter kernel"
$slicer_executable -c '
slicer.modules.jupyterkernel.installInternalJupyterServer()
'

################################################################################
# Shutdown headless environment
kill -9 $XORG_PID
rm /tmp/.X10-lock
