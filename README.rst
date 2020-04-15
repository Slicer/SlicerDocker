Docker images for 3D Slicer
===========================

Images
------

.. |slicer-base-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-base.svg
  :target: https://microbadger.com/images/slicer/slicer-base

slicer/slicer-base
  |slicer-base-images| The image used to build Slicer on CircleCI each time a Pull Request is submitted. For more details, see `.circleci/config.yml <https://github.com/Slicer/Slicer/blob/master/.circleci/config.yml>`_ 

.. |slicer-dependencies-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-dependencies.svg
  :target: https://microbadger.com/images/slicer/slicer-dependencies


Unmaintained Images
-------------------

In the process of improving the Slicer infrastructure, these images are not updated anymore. Only the ``slicer/slicer-base`` image is used for `continuous integration with CircleCI <https://github.com/Slicer/Slicer/blob/master/.circleci/config.yml>`_.

slicer/slicer-dependencies
  |slicer-dependencies-images| An image containing all the dependencies to
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

.. |slicer-test-opengl-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-test.svg
  :target: https://microbadger.com/images/slicer/slicer-test

slicer/slicer-test:opengl
  |slicer-test-opengl-images| An image based on thewtex/opengl:centos which contains configuration files to run Slicer's tests

Usage
-----

To build and package a local Slicer source tree at `~/src/Slicer` against pre-built dependencies::

  docker run --name slicer slicer/slicer-dependencies
  # Copy the generated Slicer package to the /tmp/ directory.
  docker cp slicer:$(docker cp slicer:/usr/src/Slicer-build/Slicer-build/PACKAGE_FILE.txt - | tar xO) /tmp/
  docker rm slicer

Update
------

To update the Slicer revision, first download Slicer sources::

  git clone git://github.com/Slicer/Slicer

Then download SlicerDocker sources and check out a local branch for the update::

  git clone git://github.com/Slicer/SlicerDocker
  cd SlicerDocker
  git checkout -b update-$(date +%F)

And run the update script::

  ./slicer-base/update.sh /path/to/src/Slicer
