#!/bin/sh
# Change mode to: exit if there is an error
set -e

# get data or create it
test -d /data/files || mkdir -p /data/files && chown teamspeak:teamspeak /data/files
# get logs or create them
test -d /data/logs || mkdir -p /data/logs && chown teamspeak:teamspeak /data/logs

# Mount/ Link all data files in the app
cd /app
for i in /data/*
do
    ln -sf "${i}" .
done
find -L /app -type l -delete

# Mount/ Link static files
for i in "query_ip_whitelist.txt query_ip_blacklist.txt ts3server.ini ts3server.sqlitedb ts3server.sqlitedb-shm ts3server.sqlitedb-wal .ts3server_license_accepted"
do
  ln -sf /data/"${i}" .
done

# create own init over tini and start server
export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
exec /sbin/tini -- ./ts3server license_accepted=1
