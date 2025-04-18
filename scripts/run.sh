#!/bin/bash
set -e

mkdir -p /app/feeds /app/logs /app/cache

# M.E.L.T. Config
OTEL_ENDPOINT="http://otel-collector:4318"
HOST_ID=$(hostname)

log() {
  echo "[$(date -Iseconds)] $1" | tee -a /app/logs/index.log
}

for line in $(cat /app/config/shares.list); do
  IFS=" " read -r SHARE_PATH SHARE_NAME <<< "$line"
  START_TIME=$(date +%s.%N)

  log "Indexing $SHARE_NAME at $SHARE_PATH"
  indexer.sh "$SHARE_PATH" "$SHARE_NAME" >> /app/logs/index-$SHARE_NAME.log 2>&1

  DURATION=$(echo "$(date +%s.%N) - $START_TIME" | bc)
  log "Done indexing $SHARE_NAME in ${DURATION}s"

  # Emit metric
  otel-cli metric --name "index_duration_seconds" \
    --value "$DURATION" \
    --type gauge \
    --attributes "share=$SHARE_NAME,host=$HOST_ID" \
    --endpoint "$OTEL_ENDPOINT"
done

# Start Caddy server
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
