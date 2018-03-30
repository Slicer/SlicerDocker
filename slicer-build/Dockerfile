FROM slicer/slicer-base:latest

RUN \
  #
  # Re-configure
  #
  cd /usr/src/Slicer-build && \
  cmake -DBUILD_TESTING:BOOL=OFF . && \
  #
  # Build
  #
  /usr/src/Slicer-build/BuildSlicer.sh && \
  #
  # Cleanup
  #
  cd /usr/src/Slicer-build/Slicer-build && \
  find . -name '*.o' -delete && \
  find lib -name '*.a' -delete && \
  rm -rf _CPack_Packages

WORKDIR /usr/src/Slicer-build/Slicer-build

CMD bash

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0" \
      maintainer="3D Slicer Community <slicer-devel@bwh.harvard.edu>"
