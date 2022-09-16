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
# Note: in each RUN command "apt-get update" must be called before apt-get is used.
RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' >> /etc/apt/apt.conf && \
    echo 'Dir::Cache::pkgcache "";\nDir::Cache::srcpkgcache "";' | tee /etc/apt/apt.conf.d/00_disable-cache-files

################################################################################
# get packages
# - update (without update, old cached server addresses may be used and apt-get install may fail)
# - install things
#   - basic  tools
#   - slicer dependencies
#   - awesome window manager
#   - procps to get ps (needed for DICOM listener)
#   - install ca-certs to prevent - fatal: unable to access 'https://github.com/novnc/websockify/': server certificate verification failed. CAfile: none CRLfile: none
RUN apt-get update -q -y && \
    apt-get install -q -y \
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
        procps \
        jq \
        git && \
    apt-get install -q -y --reinstall ca-certificates

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

# Current preview release (Slicer-5.0.3, 2022-07-08, rev30893)
ARG SLICER_DOWNLOAD_URL=https://download.slicer.org/bitstream/62cc52d2aa08d161a31c1af0

# Use local package:
#ADD $SLICER_ARCHIVE.tar.gz ${HOME}/

# Download package:
RUN curl -JL "$SLICER_DOWNLOAD_URL" | tar xz -C /tmp && mv /tmp/Slicer* Slicer

################################################################################
# these go after installs to avoid trivial invalidation
ENV VNCPORT=49053
ENV JUPYTERPORT=8888
ENV DISPLAY=:10

COPY xorg.conf .

################################################################################
# Set up remote desktop access - step 1/2

# Build rebind.so (required by websockify)
RUN set -x && \
    apt-get update -q -y && \
    apt-get install -y build-essential --no-install-recommends && \
    mkdir src && \
    cd src && \
    git clone https://github.com/novnc/websockify websockify && \
    cd websockify && \
    make && \
    cp rebind.so /usr/lib/ && \
    cd .. && \
    rm -rf websockify && \
    cd .. && \
    rmdir src && \
    apt-get purge -y --auto-remove build-essential

# Set up launcher for websockify
# (websockify must run in  Slicer's Python environment)
COPY websockify ./Slicer/bin/
RUN chmod +x ${HOME}/Slicer/bin/websockify

################################################################################
# Need to run Slicer as non-root because
# - mybinder requirement
# - chrome sandbox inside QtWebEngine does not support root.
RUN chown ${NB_USER} ${HOME} ${HOME}/Slicer
USER ${NB_USER}

RUN mkdir /tmp/runtime-sliceruser
ENV XDG_RUNTIME_DIR=/tmp/runtime-sliceruser

################################################################################
# Set up remote desktop access - step 2/2

# Install websockify
# Copy rebind.so into websockify folder so websockify can find it
# Install Jupyter desktop (configures noVNC connection adds a new "Desktop" option in New menu in Jupyter)

# First upgrade pip
RUN /home/sliceruser/Slicer/bin/PythonSlicer -m pip install --upgrade pip

# Now install websockify and jupyter-server-proxy (fixed at tag v1.6.0)
RUN /home/sliceruser/Slicer/bin/PythonSlicer -m pip install --upgrade websockify && \
    cp /usr/lib/rebind.so /home/sliceruser/Slicer/lib/Python/lib/python3.9/site-packages/websockify/ && \
    /home/sliceruser/Slicer/bin/PythonSlicer -m pip install notebook jupyterhub jupyterlab && \
    /home/sliceruser/Slicer/bin/PythonSlicer -m pip install -e \
        git+https://github.com/lassoan/jupyter-desktop-server#egg=jupyter-desktop-server \
        git+https://github.com/jupyterhub/jupyter-server-proxy@v1.6.0#egg=jupyter-server-proxy

################################################################################
# Install Slicer extensions

COPY start-xorg.sh .
COPY install.sh .
RUN ./install.sh ${HOME}/Slicer/Slicer && \
    rm ${HOME}/install.sh

################################################################################
EXPOSE $VNCPORT $JUPYTERPORT
COPY run.sh .
ENTRYPOINT ["/home/sliceruser/run.sh"]

CMD ["sh", "-c", "./Slicer/bin/PythonSlicer -m jupyter notebook --port=$JUPYTERPORT --ip=0.0.0.0 --no-browser --NotebookApp.default_url=/lab/"]

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
