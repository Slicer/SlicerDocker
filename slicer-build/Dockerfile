FROM slicer/slicer-base:latest

RUN cd /usr/src/Slicer-build && \
  cmake -DBUILD_TESTING:BOOL=OFF .

RUN /usr/src/Slicer-build/BuildSlicer.sh && \
  cd /usr/src/Slicer-build/Slicer-build && \
  find . -name '*.o' -delete && \
  find lib -name '*.a' -delete && \
  rm -rf _CPack_Packages
VOLUME /usr/src/Slicer-build
VOLUME /usr/src/install-prefix
WORKDIR /usr/src/Slicer-build/Slicer-build
CMD bash

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.description="An image containing a Slicer build tree along with all the dependencies to build Slicer" \
      org.label-schema.url="http://www.slicer.org" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0" \
      maintainer="3D Slicer Community <slicer-devel@bwh.harvard.edu>"
