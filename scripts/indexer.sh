#!/bin/bash
set -euo pipefail
# Args: /mnt/music music

SOURCE_PATH="$1"
NAME="$2"
FEED_PATH="/app/feeds/$NAME.rss"
CACHE_PATH="/app/cache/$NAME"
BASELINE_ARCHIVE="$CACHE_PATH/baseline.txt.gz"
LATEST_LIST="$CACHE_PATH/latest.txt"
LATEST_SORTED="$CACHE_PATH/latest.sorted"
CHANGED_LIST="$CACHE_PATH/changed.txt"

mkdir -p "$CACHE_PATH"

rsync -a --dry-run --out-format='%n' "$SOURCE_PATH"/ "$CACHE_PATH"/ > "$LATEST_LIST"

# Ensure both lists are sorted for comm; storing a sorted intermediate keeps gzip efficient.
LC_ALL=C sort -u "$LATEST_LIST" -o "$LATEST_SORTED"
rm -f "$LATEST_LIST"

if [[ -f "$BASELINE_ARCHIVE" ]]; then
    comm -13 <(gzip -cd "$BASELINE_ARCHIVE") "$LATEST_SORTED" > "$CHANGED_LIST"
else
    cp "$LATEST_SORTED" "$CHANGED_LIST"
fi

gzip -9 < "$LATEST_SORTED" > "$BASELINE_ARCHIVE.tmp"
mv "$BASELINE_ARCHIVE.tmp" "$BASELINE_ARCHIVE"
rm -f "$LATEST_SORTED"

generate_rss.sh "$NAME" "$SOURCE_PATH" "$CHANGED_LIST" > "$FEED_PATH"
