#!/bin/bash

if [ ! -f "$HOME/installed.txt" ]; then

  cp -R $DEFCONF/* $CONF

  cp $SERVER/Lib $MODS

  cp $SERVER/server.properties $DEFCONF
  cp $SERVER/whitelist.json $DEFCONF
  cp $SERVER/permissions.json $DEFCONF
  touch $DEFCONF/custom.yaml $DEFCONF/configuration.json

  ln -sb $CONF/configuration.json $SERVER/configuration.json
  ln -sb $CONF/custom.yaml $SERVER/custom.yaml
  ln -sb $CONF/permissions.json $SERVER/permissions.json
  ln -sb $CONF/whitelist.json $SERVER/whitelist.json
  ln -sb $CONF/server.properties $SERVER/server.properties

  ln -sb $DB/audit.db3 $SERVER/audit.db3
  ln -sb $DB/chat.db3 $SERVER/chat.db3
  ln -sb $DB/economy.db3 $SERVER/economy.db3
  ln -sb $DB/essentials.db3 $SERVER/essentials.db3
  ln -sb $DB/log.db3 $SERVER/log.db3
  ln -sb $DB/packet.db3 $SERVER/packet.db3
  ln -sb $DB/user.db $SERVER/user.db

  if [ ! -d "$DOCKER/worlds" ]; then
    mkdir -p $DOCKER/worlds
  fi

  ln -sb $DOCKER/worlds $SERVER/worlds

  if [ ! -d "$DOCKER/backups" ]; then
    mkdir -p $DOCKER/backups
  fi

  ln -sb $DOCKER/backups $SERVER/backups

  if [ ! -d "$MODS/Mods" ]; then
    mkdir -p $MODS/Mods
  fi

  if [ ! -d "$MODS/Lib" ]; then
    mkdir -p $MODS/Lib
  fi

  if [ ! -d "$MODS/plugins" ]; then
    mkdir -p $MODS/plugins
  fi

  if [ ! -d "$MODS/scripts" ]; then
    mkdir -p $MODS/scripts
  fi

  ln -sb $MODS/Mods $SERVER/Mods
  ln -sb $MODS/Lib $SERVER/Lib
  ln -sb $MODS/plugins $SERVER/plugins
  ln -sb $MODS/scripts $SERVER/scripts

  touch $HOME/installed.txt

fi
chmod -X $SERVER/vellum
exec "./vellum"