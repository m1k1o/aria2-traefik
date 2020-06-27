#!/bin/sh

# WebUI configuration
echo "const RPC_PORT = location.port;" > /webui/conf.js
echo "const RPC_PATH = '${RPC_PATH}';" >> /webui/conf.js
echo "const RPC_SECRET = '${RPC_SECRET:=secret}';" >> /webui/conf.js

darkhttpd /webui --port 8080 --chroot --daemon --no-listing --log /dev/null

# aria2c configuration
touch /conf/aria2.session
cp /conf/aria2.conf.tmpl /conf/aria2.conf
chown "$PUID":"$PGID" /conf/aria2.{session,conf}

# RPC secret
echo "rpc-secret=${RPC_SECRET:=secret}" >> /conf/aria2.conf

# Download settings
echo "max-overall-download-limit=${MAX_OVERALL_DOWNLOAD_LIMIT}" >> /conf/aria2.conf
echo "max-overall-upload-limit=${MAX_OVERALL_UPLOAD_LIMIT}" >> /conf/aria2.conf
echo "max-concurrent-downloads=${MAX_CONCURRENT_DOWNLOADS}" >> /conf/aria2.conf
echo "max-connection-per-server=${MAX_CONNECTION_PER_SERVER}" >> /conf/aria2.conf
echo "split=${SPLIT}" >> /conf/aria2.conf

exec s6-setuidgid "$PUID":"$PGID" aria2c --conf-path=/conf/aria2.conf --log=-
