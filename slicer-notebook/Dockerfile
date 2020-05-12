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

# install ipython widgets required for SlicerNotebookLib
RUN pip3 install ipywidgets ipycanvas ipyevents

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

ARG SLICER_ARCHIVE=Slicer-4.11.0-2020-05-14-linux-amd64
ARG SLICER_DOWNLOAD_URL=http://slicer.kitware.com/midas3/api/rest?method=midas.bitstream.download&name=Slicer-4.11.0-2020-05-14-linux-amd64.tar.gz&checksum=971ddac26fe28a962e6838bab0f455d2

# Use local package:
#ADD $SLICER_ARCHIVE.tar.gz ${HOME}/

# Download package:
RUN curl -OJL "$SLICER_DOWNLOAD_URL" && \
    tar xzf $SLICER_ARCHIVE.tar.gz && \
    rm $SLICER_ARCHIVE.tar.gz

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
# Set up remote desktop access
RUN apt-get -y -q install git

RUN pip3 install --upgrade websockify

# Websockify needs rebind.so but for some reason it is not built and
# installed automatically, so we do it manually here
RUN apt-get -y install build-essential
RUN mkdir src && \
    cd src && \
    git clone https://github.com/novnc/websockify websockify && \
    cd websockify  && \
    make && \
    cp rebind.so /usr/local/lib/ && \
    cd .. && \
    rm websockify -rf
# TODO: remove build-essential?

RUN pip3 install -e \
  git+https://github.com/lassoan/jupyter-desktop-server#egg=jupyter-desktop-server \
  git+https://github.com/jupyterhub/jupyter-server-proxy#egg=jupyter-server-proxy


################################################################################
# Need to run Slicer as non-root because
# - mybinder requirement
# - chrome sandbox inside QtWebEngine does not support root.
USER ${NB_USER}

RUN mkdir /tmp/runtime-sliceruser
ENV XDG_RUNTIME_DIR=/tmp/runtime-sliceruser

################################################################################
# Set up SlicerJupyter

ARG SLICER_JUPYTER_ARCHIVE=29057-linux-amd64-SlicerJupyter-git6993275-2020-05-14.tar.gz
ARG SLICER_JUPYTER_DOWNLOAD_URL=http://slicer.kitware.com/midas3/api/rest?method=midas.bitstream.download&name=29057-linux-amd64-SlicerJupyter-git6993275-2020-05-14.tar.gz&checksum=2e06dc51ecebd9345cea80953b5a9d5b

RUN curl -OJL "$SLICER_JUPYTER_DOWNLOAD_URL"
#COPY $SLICER_JUPYTER_ARCHIVE .

COPY start-xorg.sh .
COPY install.sh .
RUN ./install.sh ${HOME}/$SLICER_ARCHIVE/Slicer

RUN rm $SLICER_JUPYTER_ARCHIVE

################################################################################
EXPOSE $VNCPORT $JUPYTERPORT
COPY run.sh .
ENTRYPOINT ["/home/sliceruser/run.sh"]

CMD ["sh", "-c", "jupyter notebook --port=$JUPYTERPORT --ip=0.0.0.0 --no-browser"]

################################################################################
# Install Slicer application startup script

COPY .slicerrc.py .

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
