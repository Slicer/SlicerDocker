FROM slicer/slicer-build-base:latest
MAINTAINER 3D Slicer Community <slicer-devel@bwh.harvard.edu>

RUN cd /usr/src/Slicer-build && \
  cmake -DBUILD_TESTING:BOOL=OFF .

RUN /usr/src/Slicer-build/BuildSlicer.sh && \
  cd /usr/src/Slicer-build/Slicer-build && \
  find . -name '*.o' -delete && \
  rm -rf _CPack_Packages
VOLUME /usr/src/Slicer-build
WORKDIR /usr/src/Slicer-build/Slicer-build
CMD bash
