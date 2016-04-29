Docker images for 3D Slicer
===========================

Images
------

.. |slicer-build-base-images| image:: https://badge.imagelayers.io/slicer/slicer-build-base:latest.svg
  :target: https://imagelayers.io/?images=slicer/slicer-build-base:latest

slicer/slicer-build-base
  |slicer-build-base-images| The base image for *slicer/slicer-builds-deps*
  and *slicer/slicer-build*.

.. |slicer-build-deps-images| image:: https://badge.imagelayers.io/slicer/slicer-build-deps:latest.svg
  :target: https://imagelayers.io/?images=slicer/slicer-build-deps:latest

slicer/slicer-build-deps
  |slicer-build-deps-images| An image containing all the dependencies to
  build Slicer itself: ITK, VTK, CTK, Qt, etc.

.. |slicer-build-images| image:: https://badge.imagelayers.io/slicer/slicer-build-deps:latest.svg
  :target: https://imagelayers.io/?images=slicer/slicer-build-deps:latest

slicer/slicer-build
  |slicer-build-images| An image containing a Slicer build tree along with
  all the dependencies to build Slicer.

Usage
-----

To build and package a local Slicer source tree at `~/src/Slicer` against pre-built dependencies::

  docker run --name slicer slicer/slicer-build-deps
  # Copy the generated Slicer package to the /tmp/ directory.
  docker cp slicer:$(docker cp slicer:/usr/src/Slicer-build/Slicer-build/PACKAGE_FILE.txt - | tar xO) /tmp/
  docker rm slicer
