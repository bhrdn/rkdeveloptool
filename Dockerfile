FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libudev-dev \
    libusb-1.0-0-dev \
    dh-autoreconf \
    git \
    vim \
    nano \
    gdb \
    valgrind \
    strace \
    ltrace \
    htop \
    tree \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash bub && \
    usermod -aG sudo bub && \
    echo "bub ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /etc/udev/rules.d && \
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2207", MODE="0666"' >> /etc/udev/rules.d/99-rk-rockusb.rules

WORKDIR /workspace

COPY . /workspace/

RUN chown -R bub:bub /workspace

USER bub

RUN ./autogen.sh && \
    ./configure && \
    make

RUN make clean && \
    CXXFLAGS="-g -O0 -DDEBUG" ./configure && \
    make

RUN echo 'alias debug="gdb --args ./rkdeveloptool"' >> ~/.bashrc && \
    echo 'alias valgrind-run="valgrind --leak-check=full --show-leak-kinds=all ./rkdeveloptool"' >> ~/.bashrc && \
    echo 'alias strace-run="strace -f -e trace=file,network,desc ./rkdeveloptool"' >> ~/.bashrc && \
    echo 'alias build-debug="make clean && CXXFLAGS=\"-g -O0 -DDEBUG\" ./configure && make"' >> ~/.bashrc && \
    echo 'alias build-release="make clean && CXXFLAGS=\"-O2\" ./configure && make"' >> ~/.bashrc

EXPOSE 1234

CMD ["/bin/bash"]
