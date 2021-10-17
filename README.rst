Docker images for 3D Slicer
***************************

Images
======

.. |slicer-notebook-images| image:: https://img.shields.io/docker/image-size/slicer/slicer-notebook/latest
  :target: https://hub.docker.com/r/slicer/slicer-notebook

slicer/slicer-notebook
  |slicer-notebook-images| Ready-to-run Docker images containing Slicer and Jupyter. See more information below.

.. |slicer-base-images| image:: https://img.shields.io/docker/image-size/slicer/slicer-base/latest
  :target: https://hub.docker.com/r/slicer/slicer-base

slicer/slicer-base
  |slicer-base-images| The image used to build Slicer on CircleCI each time a Pull Request is submitted. For more details, see `.circleci/config.yml <https://github.com/Slicer/Slicer/blob/master/.circleci/config.yml>`_ 

Information about unmaintained images are available `here <unmaintained-images.rst>`_.

Usage of slicer-notebook image
==============================

1. Start a Jupyter server by running this command:

Linux or MacOS::

    docker run -p 8888:8888 -p49053:49053 -v "$PWD":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:2021-10-15-b3077c2

Windows::

    docker run -p 8888:8888 -p49053:49053 -v "%USERPROFILE%":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:2021-10-15-b3077c2

2. Open the link shown at the end of the command-line output (``http://127.0.0.1:8888/?token=...``) in a web browser.
