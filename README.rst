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
  |slicer-base-images| The image used to build Slicer on CircleCI each time a Pull Request is submitted. For more details, see `GitHub Actions workflow <https://github.com/Slicer/Slicer/tree/main/.github>`_

Information about unmaintained images are available `here <unmaintained-images.rst>`_.

Usage of slicer-notebook image
==============================

1. Start a Jupyter server by running this command:

Note: `slicer/slicer-notebook` images on dockerhub are outdated, therefore the examples below uses latest images from `lassoan/slicer-notebook`.

Linux or MacOS::

    docker run -p 8888:8888 -p 49053:49053 -v "$PWD":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:latest

Windows::

    docker run -p 8888:8888 -p 49053:49053 -v "%USERPROFILE%":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:latest

2. Open the link shown at the end of the command-line output (``http://127.0.0.1:8888/?token=...``) in a web browser.

Docker files for 3D Slicer
***************************

`dockerfile <https://github.com/mauigna06/SlicerMorphCloud/tree/WithWebServer>`_ that:

- Runs Slicer with GPU rendering and connects to it via vnc (using a client running in the web browser)
- Communicate with Slicer via WebServer module via REST API
