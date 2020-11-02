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

RUN apk add wget tar unzip

RUN wget https://minecraft.azureedge.net/bin-win/bedrock-server-1.16.40.02.zip && \
    mv bds-1.16.40.02.tar.xz $SERVER/bds.tar.xz

RUN tar -xf $SERVER/bds.tar.xz -C $SERVER && \
    rm -rf $SERVER/bds.tar.xz
