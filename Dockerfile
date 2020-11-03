FROM alpine:latest as setup

# DEFINE DIRECTORY STRUCTURE
ENV HOME="/mcbdx" \
    SERVER="/mcbdx/server" \
    SCRIPTS="/mcbdx/scripts" \
    DEFCONF="/mcbdx/default_config" \
    DOCKER="/docker" \
    CONF="/docker/config" \
    MODS="/docker/mods" \
    DB="/docker/db"

# CREATE DIRECTORY STRUCTURE
RUN mkdir -p $HOME && \
    mkdir -p $SERVER && \
    mkdir -p $SCRIPTS && \
    mkdir -p $DEFCONF && \
    mkdir -p $DOCKER && \
    mkdir -p $CONF && \
    mkdir -p $MODS && \
    mkdir -p $DB

RUN apk add wget tar

#COPY ./tar $SERVER


RUN wget https://github.com/substicious/mcbds-element0-linux/blob/main/tar/bds-1.16.40.02.tar.xz && \
    mv bds-1.16.40.02.tar.xz $SERVER && \
    wget https://github.com/substicious/mcbds-element0-linux/blob/main/tar/elementzero.tar.xz && \
    mv elementzero.tar.xz $SERVER && \
    wget https://github.com/substicious/mcbds-element0-linux/blob/main/tar/vellumzero.tar.xz && \
    mv vellumzero.tar.xz $SERVER

RUN tar -xzf $SERVER/bds-1.16.40.02.tar.xz -C $SERVER && \
    rm -rf $SERVER/bds-1.16.40.02.tar.xz && \
    tar -xzf $SERVER/elementzero.tar.xz -C $SERVER && \
    rm -rf $SERVER/elementzero.tar.xz && \
    tar -xzf $SERVER/vellumzero.tar.xz -C $SERVER && \
    rm -rf $SERVER/vellumzero.tar.xz
    
RUN apk del wget tar

COPY ./scripts $SCRIPTS

RUN cp -R $SCRIPTS/db/* $DB

FROM ubuntu:latest as main

# ARCH is only set to avoid repetition in Dockerfile since the binary download only supports amd64
ARG ARCH=amd64

# CONFIGURE TIMEZONE TO UTC
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN dpkg --add-architecture i386 && \
    apt update && \
    apt -y install gnupg2 software-properties-common wget && \
    wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository -y https://dl.winehq.org/wine-builds/ubuntu/ && \
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
    MODS="/docker/mods" \
    DB="/docker/db"

VOLUME $DOCKER

COPY --from=setup $HOME $HOME

ARG EASY_ADD_VERSION=0.7.0
ADD https://github.com/itzg/easy-add/releases/download/${EASY_ADD_VERSION}/easy-add_linux_${ARCH} /usr/local/bin/easy-add
RUN chmod +x /usr/local/bin/easy-add

RUN chmod +x $SCRIPTS/entrypoint.sh

RUN easy-add --var version=0.2.1 --var app=entrypoint-demoter --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=0.1.1 --var app=set-property --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=1.2.0 --var app=restify --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=0.5.0 --var app=mc-monitor --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

WORKDIR $SERVER

EXPOSE  19132/udp \
        19133/udp 

EXPOSE  19132/tcp \
        19133/tcp \
        80/tcp

ENV VERSION=LATEST \
    SERVER_PORT=19132

HEALTHCHECK --start-period=1m CMD /usr/local/bin/mc-monitor status-bedrock --host play.eutopiacraft.ga --port $SERVER_PORT

ENTRYPOINT $SCRIPTS/entrypoint.sh