FROM thewtex/centos-build:latest
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

## This will configure and build Qt in RELEASE against the zlib and openssl previously built
RUN wget http://packages.kitware.com/download/item/6175/qt-everywhere-opensource-src-4.8.6.tar.gz && \
 md5=$(md5sum ./qt-everywhere-opensource-src-4.8.6.tar.gz | awk '{ print $1 }') && \
 [ $md5 == "2edbe4d6c2eff33ef91732602f3518eb" ] && \
 tar -xzvf qt-everywhere-opensource-src-4.8.6.tar.gz && \
 rm qt-everywhere-opensource-src-4.8.6.tar.gz && \
 mv qt-everywhere-opensource-src-4.8.6 qt-everywhere-opensource-release-src-4.8.6 && \
 mkdir qt-everywhere-opensource-release-build-4.8.6 && \
 cd qt-everywhere-opensource-release-src-4.8.6 && \
 LD=${CXX} ./configure -prefix /usr/src/qt-everywhere-opensource-release-build-4.8.6 \
   -release \
   -opensource -confirm-license \
   -no-qt3support \
   -webkit \
   -nomake examples -nomake demos \
   -openssl -I /usr/src/openssl-1.0.1e/include -L /usr/src/openssl-1.0.1e && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  find . -name '*.o' -delete

# Slicer master 2016-01-09
ENV SLICER_VERSION 3eb19c2c7dd9d0432389176642f72646288dbdc0
RUN git clone https://github.com/Slicer/Slicer.git && \
  cd Slicer && \
  git checkout ${SLICER_VERSION}
RUN  mkdir /usr/src/Slicer-build
WORKDIR /usr/src/Slicer-build
RUN cmake \
    "-DCMAKE_CXX_FLAGS:STRING=-static-libstdc++" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
      /usr/src/Slicer && \
  make -j$(grep -c processor /proc/cpuinfo)
RUN cmake --build /usr/src/Slicer-build/Slicer-build --config Release --target package
