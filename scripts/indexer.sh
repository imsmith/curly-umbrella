#!/bin/bash
# Args: /mnt/music music

SOURCE_PATH="$1"
NAME="$2"
FEED_PATH="/app/feeds/$NAME.rss"
CACHE_PATH="/app/cache/$NAME"

mkdir -p "$CACHE_PATH"

rsync -a --dry-run --out-format='%n' "$SOURCE_PATH"/ "$CACHE_PATH"/ > "$CACHE_PATH/latest.txt"
comm -13 <(sort "$CACHE_PATH/baseline.txt" 2>/dev/null || true) <(sort "$CACHE_PATH/latest.txt") > "$CACHE_PATH/changed.txt"
mv "$CACHE_PATH/latest.txt" "$CACHE_PATH/baseline.txt"

generate_rss.sh "$NAME" "$SOURCE_PATH" "$CACHE_PATH/changed.txt" > "$FEED_PATH"
