FROM slicer/buildenv-qt5-centos7:latest

# Slicer main 2024-04-08
ENV SLICER_VERSION 996e9fd608

RUN \
  #
  # Download sources
  #
  cd /usr/src && \
  git clone https://github.com/Slicer/Slicer && \
  cd Slicer && \
  git reset --hard ${SLICER_VERSION} && \
  #
  # Configure
  #
  mkdir /usr/src/Slicer-build && \
  cd /usr/src/Slicer-build && \
  cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_JOB_POOLS:STRING="compile=16;link=8" \
    -DCMAKE_JOB_POOL_COMPILE:STRING=compile \
    -DCMAKE_JOB_POOL_LINK:STRING=link \
    -DQt5_DIR:PATH=${Qt5_DIR} \
    -DSlicer_BUILD_ITKPython:BOOL=OFF \
    -DSlicer_INSTALL_ITKPython:BOOL=OFF \
      /usr/src/Slicer && \
  #
  # Split the superbuild commands (what is executed by ninja) into building Slicer's
  # dependencies, and building Slicer itself.
  #   NOTE: xx00, xx01... files are created by `csplit` from the `ninja ...` output.
  #
  cd /usr/src/Slicer-build && \
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
    echo "cmake --build /usr/src/Slicer-build/Slicer-build --target package -- \$BUILD_TOOL_FLAGS | tee /usr/src/Slicer-build/Slicer-build/PACKAGES.txt" >> BuildSlicer.sh && \
    echo "cat /usr/src/Slicer-build/Slicer-build/PACKAGES.txt | gawk 'match(\$0, /CPack: - package: (.*) generated/, a) {print a[1]}' > /usr/src/Slicer-build/Slicer-build/PACKAGE_FILE.txt" >> BuildSlicer.sh && \
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
  find . -maxdepth 1 -type d  -name Slicer-prefix -o -type d -name "*-prefix"  -exec rm -rf "{}" \; && \
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
  mkdir -p ITK-build/Wrapping && find ITK-build/Wrapping -name '*.cpp' -delete -o -name '*.xml' -delete && \
  rm -rf ITK-build/Wrapping/Generators/castxml* && \
  # Remove source files
  find CTK -name '*.cpp' -delete && \
  find DCMTK -name '*.cc' -delete && \
  find ITK -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find VTK -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  rm -rf CTK-build/PythonQt/generated* && \
  rm -rf /usr/src/Slicer

WORKDIR /usr/src/Slicer-build

# Build-time metadata as defined at http://label-schema.org
# BUILD_DATE is omitted to avoid unneeded rebuild
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0" \
      maintainer="3D Slicer Community <slicer-devel@bwh.harvard.edu>"
