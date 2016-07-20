#!/bin/sh

export PATH=$PATH:/usr/local/bin
export NODE_PATH=$NODE_PATH:/usr/lib/node_modules

case "$1" in
  start)
  [ -d var/run/forever ] || mkdir /var/run/forever
  exec forever --sourceDir=/root/project-delta -p /var/run/forever start bin/www
  ;;

  stop)
  exec forever stopall
  ;;
esac

exit 0

