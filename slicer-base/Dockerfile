FROM thewtex/centos-build:latest
MAINTAINER 3D Slicer Community <slicer-devel@bwh.harvard.edu>

RUN yum update -y && \
  yum install -y \
    fontconfig-devel \
    libX11-devel \
    libXt-devel \
    libXext-devel \
    libXrender-devel \
    libGLU-devel \
    mesa-libOSMesa-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    ncurses \
    vim

WORKDIR /usr/src

# This will download, then build zlib and openssl in the current folder
RUN wget --no-check-certificate https://gist.githubusercontent.com/jcfr/9513568/raw/0dc6707197702e3f7f6653a1940cb467378a065c/get-and-build-openssl-for-slicer.sh && \
  chmod u+x get-and-build-openssl-for-slicer.sh && \
  ./get-and-build-openssl-for-slicer.sh

## This will configure and build Qt in RELEASE against the zlib and openssl previously built
RUN wget http://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz && \
 md5=$(md5sum ./qt-everywhere-opensource-src-4.8.7.tar.gz | awk '{ print $1 }') && \
 [ $md5 == "d990ee66bf7ab0c785589776f35ba6ad" ] && \
 tar -xzvf qt-everywhere-opensource-src-4.8.7.tar.gz && \
 rm qt-everywhere-opensource-src-4.8.7.tar.gz && \
 mv qt-everywhere-opensource-src-4.8.7 qt-everywhere-opensource-release-src-4.8.7 && \
 mkdir install-prefix && \
 cd qt-everywhere-opensource-release-src-4.8.7 && \
 LD=${CXX} ./configure -prefix /usr/src/install-prefix \
   -release \
   -opensource -confirm-license \
   -no-qt3support \
   -webkit \
   -nomake examples -nomake demos \
   -openssl -I /usr/src/openssl-1.0.1e/include -L /usr/src/openssl-1.0.1e && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  cd .. &&\
  rm -rf qt-everywhere-opensource-src-build-4.8.7 && \
  rm -rf /usr/src/install-prefix/doc
ENV PATH /usr/src/install-prefix/bin:$PATH

# Slicer master 2017-11-05
ENV SLICER_VERSION 26553
RUN svn checkout -r ${SLICER_VERSION} http://svn.slicer.org/Slicer4/trunk Slicer && \
  cd Slicer && \
  rm -rf .svn
VOLUME /usr/src/Slicer
RUN  mkdir /usr/src/Slicer-build
WORKDIR /usr/src/Slicer-build
RUN cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=MinSizeRel \
    -DSlicer_BUILD_ITKPython:BOOL=ON \
    -DSlicer_INSTALL_ITKPython:BOOL=ON \
      /usr/src/Slicer
# Split the superbuild commands (what is executed by ninja) into building Slicer's
# dependencies, and building Slicer itself.
#   NOTE: xx00, xx01... files are created by `csplit` from the `ninja ...` output.
RUN ninja -t commands Slicer | csplit - '/Slicer-mkdir/' && \
  echo '#!/bin/bash' > BuildSlicerDependencies.sh && \
    echo "set -e" >> BuildSlicerDependencies.sh && \
    echo "set -x" >> BuildSlicerDependencies.sh && \
    echo "set -o pipefail" >> BuildSlicerDependencies.sh && \
    echo "set -o" >> BuildSlicerDependencies.sh && \
    while IFS='' read -r line || [[ -n "$line" ]]; do \
      echo "$line || exit \$?" >> BuildSlicerDependencies.sh; \
    done < xx00 && \
    chmod +x BuildSlicerDependencies.sh && \
    rm xx00 && \
  echo '#!/bin/bash' > BuildSlicer.sh && \
    echo "set -e" >> BuildSlicer.sh && \
    echo "set -x" >> BuildSlicer.sh && \
    echo "set -o pipefail" >> BuildSlicer.sh && \
    echo "set -o" >> BuildSlicer.sh && \
    head -n 5 xx01 > xx01-no-slicer-build && \
    while IFS='' read -r line || [[ -n "$line" ]]; do \
      echo "$line || exit \$?" >> BuildSlicer.sh; \
    done < xx01-no-slicer-build && \
    echo "cmake --build /usr/src/Slicer-build/Slicer-build -- \$BUILD_TOOL_FLAGS" >> BuildSlicer.sh && \
    echo "cmake --build /usr/src/Slicer-build/Slicer-build --target package -- \$BUILD_TOOL_FLAGS | tee ./PACKAGES.txt" >> BuildSlicer.sh && \
    echo "cat ./PACKAGES.txt | gawk 'match(\$0, /CPack: - package: (.*) generated/, a) {print a[1]}' > PACKAGE_FILE.txt" >> BuildSlicer.sh && \
    echo "tar -C /usr/src/install-prefix -xzf \$(head -n1 PACKAGE_FILE.txt)" >> BuildSlicer.sh && \
    chmod +x BuildSlicer.sh && \
    rm xx01 xx01-no-slicer-build
RUN ./BuildSlicerDependencies.sh && \
  find . -name '*.o' -delete && \
  rm -rf SimpleITK-install SimpleITK-build && \
  rm -rf \
    curl/.git \
    CTK/.git \
    DCMTK/.git \
    ITKv4/.git \
    JsonCpp/.git \
    OpenIGTLink/.git \
    ParameterSerializer/.git \
    qRestAPI/.git \
    RapidJSON/.git \
    SlicerExecutionModel/.git \
    VTKv8/.git  && \
  find ITKv4-build/Wrapping -name '*.cpp' -delete -o -name '*.xml' -delete && \
  rm -rf ITKv4-build/Wrapping/Generators/castxml* && \
  rm *.tgz && \
  mv python-install .. && rm -rf python* Python* && mv ../python-install . && \
  find curl -name '*.c' -delete && \
  find CTK -name '*.cpp' -delete && \
  find DCMTK -name '*.cc' -delete && \
  find ITKv4 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find VTKv8 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  rm -rf CTK-build/PythonQt/generated*

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.description="Base image for slicer/slicer-builds-deps and slicer/slicer-build" \
      org.label-schema.url="http://www.slicer.org" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
