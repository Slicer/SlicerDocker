FROM debian:bullseye-20200422-slim

################################################################################
# Prevent apt-get from prompting for keyboard choice
#  https://superuser.com/questions/1356914/how-to-install-xserver-xorg-in-unattended-mode
ENV DEBIAN_FRONTEND=noninteractive

################################################################################
# Remove documentation to save hard drive space
#  https://askubuntu.com/questions/129566/remove-documentation-to-save-hard-drive-space
COPY etc/dpkg/dpkg.cfg.d/01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

################################################################################
# - update apt, set up certs, run netselect to get fast mirror
# - reduce apt gravity
# - and disable caching
#   from https://blog.sleeplessbeastie.eu/2017/10/02/how-to-disable-the-apt-cache/
RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' >> /etc/apt/apt.conf && \
    echo 'Dir::Cache::pkgcache "";\nDir::Cache::srcpkgcache "";' | tee /etc/apt/apt.conf.d/00_disable-cache-files && \
    apt-get update -q -y

################################################################################
# get packages
# - update
# - install things
#   - basic  tools
#   - slicer dependencies
#   - awesome window manager
RUN apt-get install -q -y \
 vim net-tools curl \
 libgl1-mesa-glx \
 xserver-xorg-video-dummy \
 libxrender1 \
 libpulse0 \
 libpulse-mainloop-glib0  \
 libnss3  \
 libxcomposite1 \
 libxcursor1 \
 libfontconfig1 \
 libxrandr2 \
 libasound2 \
 libglu1 \
 x11vnc \
 awesome \
 python3 python3-pip python3-setuptools \
 jq

################################################################################
# install jupyter
RUN pip3 install jupyter


################################################################################
# set up user
ENV NB_USER sliceruser
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
            --gecos "Default user" \
            --uid ${NB_UID} \
            ${NB_USER}

WORKDIR ${HOME}

################################################################################
# Download and unpack Slicer
#RUN curl -OJL "http://slicer.kitware.com/midas3/download?bitstream=887990" && \
#    tar xzf Slicer-4.10.0-linux-amd64.tar.gz

ARG SLICER_ARCHIVE=Slicer-4.11.0-2020-05-11-linux-amd64
ADD $SLICER_ARCHIVE.tar.gz ${HOME}/

################################################################################
# these go after installs to avoid trivial invalidation
ENV VNCPORT=49053
ENV JUPYTERPORT=8888
ENV DISPLAY=:10

COPY xorg.conf .

################################################################################
# mybinder requirement
RUN chown ${NB_USER} ${HOME} ${HOME}/Slicer-*

################################################################################
# trying nbnovnc
RUN apt-get -y -q install \
  git \
  novnc \
  sudo \
  supervisor \
  tightvncserver \
  xinit \
  websockify

RUN pip3 install -e \
  git+https://github.com/ryanlovett/nbnovnc#egg=nbnovnc \
  git+https://github.com/jupyterhub/jupyter-server-proxy#egg=jupyter-server-proxy

RUN jupyter serverextension enable  --py nbnovnc && \
    jupyter nbextension     install --py nbnovnc && \
    jupyter nbextension     enable  --py nbnovnc

################################################################################
# Need to run Slicer as non-root because
# - mybinder requirement
# - chrome sandbox inside QtWebEngine does not support root.
USER ${NB_USER}

RUN mkdir /tmp/runtime-sliceruser
ENV XDG_RUNTIME_DIR=/tmp/runtime-sliceruser

################################################################################
# Set up SlicerJupyter
COPY 29054-linux-amd64-SlicerJupyter-git08d133c-2020-05-11.tar.gz .
COPY start-xorg.sh .
COPY install.sh .
RUN ./install.sh ${HOME}/$SLICER_ARCHIVE/Slicer

################################################################################
EXPOSE $VNCPORT $JUPYTERPORT
COPY run.sh .
ENTRYPOINT ["/home/sliceruser/run.sh"]

CMD ["sh", "-c", "jupyter notebook --port=$JUPYTERPORT --ip=0.0.0.0 --no-browser"]

################################################################################
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
