FROM nvidia/cuda:10.0-base
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y python3.7 python3-pip python3.7-dev \
vim build-essential devscripts \
gawk wget git automake autoconf sox gfortran libtool subversion \
libopencv-dev build-essential checkinstall cmake pkg-config yasm libtiff5-dev \
libjpeg-dev libavcodec-dev libavformat-dev libswscale-dev \
libdc1394-22-dev libxine2-dev software-properties-common \
libv4l-dev libtbb-dev libqt4-dev libgtk2.0-dev \
libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils ffmpeg \
libeigen3-dev liblog4cxx-dev libboost-all-dev imagemagick parallel xmlstarlet \
&& rm -rf /var/lib/apt/lists
RUN mkdir pidocs-soft
WORKDIR /pidocs-soft
##### COPY DETECTRON
COPY build-resource/detectron2 ./
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
# RUN update-alternatives --config python3
# RUN pip3 install torch torchvision tqdm
# RUN pip3 install .
##### FINAL INSTALLS
COPY build-resource/.bashrc /root/
WORKDIR /pidocs-soft/
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ./anaconda.sh
RUN bash anaconda.sh -b
COPY build-resource/detect_env.yml /pidocs-soft/
RUN ~/anaconda3/bin/conda init bash
RUN . ~/.bashrc
RUN ~/anaconda3/bin/conda env create -f detect_env.yml
RUN . /root/.bashrc && conda init bash && conda activate detect && python3 -m pip install -e .
# RUN python3 -m pip install -e . 
##### RUN
WORKDIR /root
COPY build-resource/run.sh ./
CMD . /root/.bashrc && conda init bash && conda activate detect && bash /root/run.sh && exec bash 
