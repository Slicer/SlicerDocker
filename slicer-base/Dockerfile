FROM dockbuild/centos5:latest

WORKDIR /usr/src

ENV PATH=/usr/src/install-prefix/bin:${PATH}

RUN \
  yum update -y && \
  #
  # Qt dependencies: https://doc.qt.io/archives/qt-4.8/requirements-x11.html
  #
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
    vim \
  && \
  #
  # This will download, then build zlib and openssl in the current folder
  #
  cd /usr/src && \
  curl -LO https://gist.githubusercontent.com/jcfr/9513568/raw/4a458588f68caeca18abc2c399666f928ee44f09/get-and-build-openssl-for-slicer.sh && \
  chmod u+x get-and-build-openssl-for-slicer.sh && \
  ./get-and-build-openssl-for-slicer.sh && \
  rm -f get-and-build-openssl-for-slicer.sh && \
  #
  # Download Qt sources
  #
  QT_ROOT=qt-everywhere-opensource-src-4.8.7 && \
  curl -LO http://download.qt.io/official_releases/qt/4.8/4.8.7/${QT_ROOT}.tar.gz && \
  echo "d990ee66bf7ab0c785589776f35ba6ad  ${QT_ROOT}.tar.gz" > ${QT_ROOT}.tar.gz.md5 && \
  md5sum -c ${QT_ROOT}.tar.gz.md5 && \
  tar -xzvf ${QT_ROOT}.tar.gz && \
  rm -f ${QT_ROOT}.tar.gz && \
  rm -f ${QT_ROOT}.tar.gz.md5 && \
  QT_SRC_DIR=/usr/src/qt-everywhere-opensource-release-src-4.8.7 && \
  mv ${QT_ROOT} ${QT_SRC_DIR} && \
  #
  # Build Qt: This will configure and build Qt in RELEASE against the zlib and openssl previously built
  #
  cd /usr/src && \
  QT_INSTALL_DIR=/usr/src/install-prefix && \
  mkdir ${QT_INSTALL_DIR} && \
  cd ${QT_SRC_DIR} && \
  ./configure -prefix ${QT_INSTALL_DIR} \
                     -release \
                     -opensource -confirm-license \
                     -no-qt3support \
                     -webkit \
                     -nomake examples -nomake demos \
                     -openssl -I /usr/src/openssl-1.0.1h/include   -L /usr/src/openssl-1.0.1h/lib \
  && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  rm -rf ${QT_SRC_DIR} && \
  rm -rf ${QT_INSTALL_DIR}/q3porting.xml && \
  rm -rf ${QT_INSTALL_DIR}/demos && \
  rm -rf ${QT_INSTALL_DIR}/doc && \
  rm -rf ${QT_INSTALL_DIR}/examples && \
  rm -rf ${QT_INSTALL_DIR}/phrasebooks && \
  rm -rf ${QT_INSTALL_DIR}/tests && \
  rm -rf ${QT_INSTALL_DIR}/translations && \

VOLUME /usr/src/Slicer
WORKDIR /usr/src/Slicer-build

# Slicer master 2018-03-25
ENV SLICER_VERSION 27106
RUN svn checkout -r ${SLICER_VERSION} http://svn.slicer.org/Slicer4/trunk Slicer && \
  cd Slicer && \
  rm -rf .svn && \
  mkdir /usr/src/Slicer-build && \
  cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=MinSizeRel \
    -DSlicer_BUILD_ITKPython:BOOL=ON \
    -DSlicer_INSTALL_ITKPython:BOOL=ON \
      /usr/src/Slicer && \
  #
  # Split the superbuild commands (what is executed by ninja) into building Slicer's
  # dependencies, and building Slicer itself.
  #   NOTE: xx00, xx01... files are created by `csplit` from the `ninja ...` output.
  #
  ninja -t commands Slicer | csplit - '/Slicer-mkdir/' && \
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
    rm xx01 xx01-no-slicer-build && \
  #
  # Build dependencies
  #
  ./BuildSlicerDependencies.sh && \
  #
  # Cleanup
  #
  # Remove all object files
  find . -name '*.o' -delete && \
  # Remove all git directories
  find . -name .git -type d -prune -exec rm -rf "{}" \; && \
  # Remove files
  rm -f *.cmake *.txt *.applied *.updated *.in *.tcl Makefile && \
  rm -f *.tgz *.tar.gz *.zip && \
  rm -rf CMakeFiles && \
  # Remove all python-* directories except python-install
  find . -maxdepth 1 -type d  -name python-install -o -type d -name "python-*" -exec rm -rf "{}" \; && \
  rm -rf NUMPY && \
  rm -rf SimpleITK* && \
  rm -rf Python-2* && \
  # Remove all *-prefix directories
  find . -maxdepth 1 -type d  -name "*-prefix"  -exec rm -rf "{}" \; && \
  # Remove uneeded source and build tree
  rm -rf \
    bzip2 bzip2-build \
    curl curl-build \
    LibArchive LibArchive-build \
    PCRE PCRE-build \
    Swig Swig-build \
    zlib zlib-build \
  && \
  # Remove ITKPython wrapping
  mkdir -p ITKv4-build/Wrapping && find ITKv4-build/Wrapping -name '*.cpp' -delete -o -name '*.xml' -delete && \
  rm -rf ITKv4-build/Wrapping/Generators/castxml* && \
  # Remove source files
  find CTK -name '*.cpp' -delete && \
  find DCMTK -name '*.cc' -delete && \
  find ITKv4 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find VTKv9 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
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
      org.label-schema.schema-version="1.0" \
      maintainer="3D Slicer Community <slicer-devel@bwh.harvard.edu>"
