# Docker images for 3D Slicer

## Unmaintained Images

In the process of improving the Slicer infrastructure, these images are
not updated anymore. Only the `slicer/slicer-base` image is used for
continuous integration with [GitHub Actions workflow](https://github.com/Slicer/Slicer/tree/main/.github).

### slicer/slicer-dependencies

[![slicer-dependencies-images](https://img.shields.io/docker/image-size/slicer/slicer-dependencies/latest)](https://hub.docker.com/r/slicer/slicer-dependencies)
An image containing all the dependencies to build Slicer itself:
ITK, VTK, CTK, Qt, etc.

### slicer/slicer-build

[![slicer-build-images](https://img.shields.io/docker/image-size/slicer/slicer-build/latest)](https://hub.docker.com/r/slicer/slicer-build)
An image containing a Slicer build tree along with all the
dependencies to build Slicer.

### slicer/slicer-test

[![slicer-test-images](https://img.shields.io/docker/image-size/slicer/slicer-test/latest)](https://hub.docker.com/r/slicer/slicer-test)
An image containing a Slicer build and test tree along with all the
dependencies to build Slicer.

### slicer/slicer-test:opengl

[![slicer-test-opengl-images](https://img.shields.io/docker/image-size/slicer/slicer-test/opengl)](https://hub.docker.com/r/slicer/slicer-test)
An image based on thewtex/opengl:centos which contains configuration
files to run Slicer's tests

## Usage

To build and package a local Slicer source tree at `~/src/Slicer` 
against pre-built dependencies:

```
docker run --name slicer slicer/slicer-dependencies
# Copy the generated Slicer package to the /tmp/ directory.
docker cp slicer:$(docker cp slicer:/usr/src/Slicer-build/Slicer-build/PACKAGE_FILE.txt - | tar xO) /tmp/
docker rm slicer
```

## Update

To update the Slicer revision, first download Slicer sources:

```
git clone https://github.com/Slicer/Slicer
```

Then download SlicerDocker sources and check out a local branch for the update:

```
git clone git@github.com:Slicer/SlicerDocker
cd SlicerDocker
git checkout -b update-$(date +%F)
```

And run the update script:

```
./slicer-base/update.sh /path/to/src/Slicer
```
