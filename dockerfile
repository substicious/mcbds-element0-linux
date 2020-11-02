FROM alpine:latest as setup

# DEFINE DIRECTORY STRUCTURE
ENV HOME="/mcbdx" \
    SERVER="/mcbdx/server" \
    SCRIPTS="/mcbdx/scripts" \
    DEFCONF="/mcbdx/default_config" \
    DOCKER="/docker" \
    CONF="/docker/config" \
    MODS="/docker/mods"

# CREATE DIRECTORY STRUCTURE
RUN mkdir -p $HOME && \
    mkdir -p $SERVER && \
    mkdir -p $SCRIPTS && \
    mkdir -p $DEFCONF && \
    mkdir -p $DOCKER && \
    mkdir -p $CONF && \
    mkdir -p $MODS 

RUN apk add wget tar

RUN wget https://github.com/substicious/mcbds-element0-linux/blob/main/tar/bds-1.16.40.02.tar.xz && \
    mv bds-1.16.40.02.tar.xz $SERVER/bds.tar.xz

RUN tar -xf $SERVER/bds.tar.xz -C $SERVER && \
    rm -rf $SERVER/bds.tar.xz

RUN apk del wget tar

COPY ./scripts $SCRIPTS

FROM debain:stable-slim as main

# ARCH is only set to avoid repetition in Dockerfile since the binary download only supports amd64
ARG ARCH=amd64

# CONFIGURE TIMEZONE TO UTC
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN dpkg --add-architecture i386 && \
    apt update && \
    apt -y install gnupg2 software-properties-common && \
    wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository -y https://dl.winehq.org/wine-builds/debian/ && \
    wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add - && \
    echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list && \
    apt update

RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    curl \
    libcurl4 \
    nano \
    tar \
    unzip && \
    apt install --install-recommends winehq-stable -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# CONFIGURE SERVER
ENV HOME="/mcbdx" \
    SERVER="/mcbdx/server" \
    SCRIPTS="/mcbdx/scripts" \
    DEFCONF="/mcbdx/default_config" \
    DOCKER="/docker" \
    CONF="/docker/config" \
    MODS="/docker/mods"

VOLUME $DOCKER

COPY --from=builder $HOME $HOME

