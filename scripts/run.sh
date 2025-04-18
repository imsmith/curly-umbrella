#!/bin/bash
set -e

mkdir -p /app/feeds
mkdir -p /app/logs

# Index all shares and generate RSS
while read -r path name; do
    echo "Indexing: $name ($path)"
    indexer.sh "$path" "$name" >> /app/logs/index-$name.log 2>&1
done < /app/config/shares.list

# Optional: ship logs to log server (adjust as needed)
curl -F "file=@/app/logs/index-music.log" http://logserver.local/upload

# Start Caddy
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
