Docker images for 3D Slicer
===========================

Images
------

.. |slicer-build-deps-images| image:: https://badge.imagelayers.io/slicer/slicer-build-deps:latest.svg
  :target: https://imagelayers.io/?images=slicer/slicer-build-deps:latest

slicer/slicer-build-deps
  |slicer-build-deps-images| An image containing all the dependencies to
  build Slicer itself: ITK, VTK, CTK, Qt, etc.

Usage
-----

To build and package Slicer against pre-built dependencies::

  docker run --name slicer slicer/slicer-build-deps
  # Here /usr/src/Slicer-build/Slicer-build/Slicer-4.5.0-2016-02-23-linux-amd64.tar.gz
  # is the generated Slicer package for Linux.
  docker cp slicer:/usr/src/Slicer-build/Slicer-build/Slicer-4.5.0-2016-02-23-linux-amd64.tar.gz /tmp/
  docker rm slicer
