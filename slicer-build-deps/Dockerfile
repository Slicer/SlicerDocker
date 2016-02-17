FROM thewtex/centos-build:v1.0.0
MAINTAINER 3D Slicer Community <slicer-devel@bwh.harvard.edu>

RUN yum update -y && \
  yum install -y \
    libX11-devel \
    libXt-devel \
    libXext-devel \
    libXrender-devel \
    libGLU-devel \
    mesa-libOSMesa-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    ncurses

WORKDIR /usr/src

# This will download, then build zlib and openssl in the current folder
RUN wget --no-check-certificate https://gist.githubusercontent.com/jcfr/9513568/raw/21f4e4cabca5ad03435ecc17ab546dab5e2c1a2f/get-and-build-openssl-for-slicer.sh && \
  chmod u+x get-and-build-openssl-for-slicer.sh && \
  ./get-and-build-openssl-for-slicer.sh
VOLUME /usr/src/openssl-1.0.1e

## This will configure and build Qt in RELEASE against the zlib and openssl previously built
RUN wget http://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz && \
 md5=$(md5sum ./qt-everywhere-opensource-src-4.8.7.tar.gz | awk '{ print $1 }') && \
 [ $md5 == "d990ee66bf7ab0c785589776f35ba6ad" ] && \
 tar -xzvf qt-everywhere-opensource-src-4.8.7.tar.gz && \
 rm qt-everywhere-opensource-src-4.8.7.tar.gz && \
 mv qt-everywhere-opensource-src-4.8.7 qt-everywhere-opensource-release-src-4.8.7 && \
 mkdir qt-everywhere-opensource-release-build-4.8.7 && \
 cd qt-everywhere-opensource-release-src-4.8.7 && \
 LD=${CXX} ./configure -prefix /usr/src/qt-everywhere-opensource-release-build-4.8.7 \
   -release \
   -opensource -confirm-license \
   -no-qt3support \
   -webkit \
   -nomake examples -nomake demos \
   -openssl -I /usr/src/openssl-1.0.1e/include -L /usr/src/openssl-1.0.1e && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  find . -name '*.o' -delete && \
  find . -name '*.cpp' -delete && \
  rm -rf doc && \
  rm -rf src/3rdparty
VOLUME /usr/src/qt-everywhere-opensource-release-build-4.8.7
VOLUME /usr/src/qt-everywhere-opensource-src-build-4.8.7

# Slicer master 2016-02-14
ENV SLICER_VERSION a91a98e2b1d310c84df11387bdeca23e647d0564
RUN git clone https://github.com/Slicer/Slicer.git && \
  cd Slicer && \
  git checkout ${SLICER_VERSION}
VOLUME /usr/src/Slicer
RUN  mkdir /usr/src/Slicer-build
WORKDIR /usr/src/Slicer-build
RUN cmake \
    -G Ninja \
    "-DCMAKE_CXX_FLAGS:STRING=-static-libstdc++" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DSlicer_BUILD_ITKPython:BOOL=ON \
    -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.7/bin/qmake \
      /usr/src/Slicer
# Split the superbuild into building Slicer's dependencies and building Slicer
# itself.
RUN ninja -t commands Slicer | csplit - '/Slicer-mkdir/' && \
  echo "#!/bin/sh" > BuildSlicerDependencies.sh && \
    cat xx00 >> BuildSlicerDependencies.sh && \
    chmod +x BuildSlicerDependencies.sh && \
    rm xx00 && \
  echo "#!/bin/sh" > BuildSlicer.sh && \
    head -n 5 xx01 >> BuildSlicer.sh && \
    echo "cmake --build /usr/src/Slicer-build/Slicer-build --config Release --target package" >> BuildSlicer.sh && \
    chmod +x BuildSlicer.sh && \
    rm xx01
RUN ./BuildSlicerDependencies.sh && \
  find . -name '*.o' -delete && \
  rm -rf SimpleITK-install SimpleITK-build && \
  rm -rf VTKv6/.git ITKv4/.git && \
  find ITKv4-build/Wrapping -name '*.cpp' -delete -o -name '*.xml' -delete && \
  rm -rf ITKv4-build/Wrapping/Generators/castxml* && \
  rm *.tgz && \
  find VTKv6 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find ITKv4 -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find DCMTK -name '*.cc' -delete && \
  rm -rf CTK-build/PythonQt/generated*
VOLUME /usr/src/Slicer-build
CMD ./BuildSlicer.sh
