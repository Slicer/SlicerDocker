FROM slicer/slicer-build-base:latest
MAINTAINER 3D Slicer Community <slicer-devel@bwh.harvard.edu>

RUN /usr/src/Slicer-build/BuildSlicer.sh
VOLUME /usr/src/Slicer-build
WORKDIR /usr/src/Slicer-build/Slicer-build
CMD bash
