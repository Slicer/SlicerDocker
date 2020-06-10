Docker images for 3D Slicer
***************************

Images
======

.. |slicer-notebook-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-notebook.svg
  :target: https://microbadger.com/images/slicer/slicer-notebook

slicer/slicer-notebook
  |slicer-notebook-images| Ready-to-run Docker images containing Slicer and Jupyter. 

.. |slicer-base-images| image:: https://images.microbadger.com/badges/image/slicer/slicer-base.svg
  :target: https://microbadger.com/images/slicer/slicer-base

slicer/slicer-base
  |slicer-base-images| The image used to build Slicer on CircleCI each time a Pull Request is submitted. For more details, see `.circleci/config.yml <https://github.com/Slicer/Slicer/blob/master/.circleci/config.yml>`_ 

Information about unmaintained images are available `here <unmaintained-images.rst>`_.

slicer-notebook
===============

Linux::

    docker run -p 8888:8888 -p49053:49053 -v "$PWD":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:2020-05-15-89b6bb5

Windows::

    docker run -p 8888:8888 -p49053:49053 -v "%USERPROFILE%":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:2020-05-15-89b6bb5

Then open the link shown at the end of the command-line output (``http://127.0.0.1:8888/?token=...``) in a web browser.
