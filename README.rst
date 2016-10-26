Docker images for 3D Slicer
===========================

Images
------

.. |slicer-build-base-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-build-base.svg
  :target: https://microbadger.com/images/slicer/slicer-build-base

slicer/slicer-build-base
  |slicer-build-base-images| The base image for *slicer/slicer-builds-deps*
  and *slicer/slicer-build*.

.. |slicer-build-deps-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-build-deps.svg
  :target: https://microbadger.com/images/slicer/slicer-build-deps

slicer/slicer-build-deps
  |slicer-build-deps-images| An image containing all the dependencies to
  build Slicer itself: ITK, VTK, CTK, Qt, etc.

.. |slicer-build-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-build.svg
  :target: https://microbadger.com/images/slicer/slicer-build

slicer/slicer-build
  |slicer-build-images| An image containing a Slicer build tree along with
  all the dependencies to build Slicer.

.. |slicer-test-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-test.svg
  :target: https://microbadger.com/images/slicer/slicer-test

slicer/slicer-test
  |slicer-test-images| An image containing a Slicer build and test tree along with
  all the dependencies to build Slicer.

Usage
-----

To build and package a local Slicer source tree at `~/src/Slicer` against pre-built dependencies::

  docker run --name slicer slicer/slicer-build-deps
  # Copy the generated Slicer package to the /tmp/ directory.
  docker cp slicer:$(docker cp slicer:/usr/src/Slicer-build/Slicer-build/PACKAGE_FILE.txt - | tar xO) /tmp/
  docker rm slicer
