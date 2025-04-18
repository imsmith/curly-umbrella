#!/bin/bash
# Usage: generate_rss.sh share_name /mnt/share /path/to/changed.txt

SHARE_NAME="$1"
BASE_PATH="$2"
CHANGE_FILE="$3"

echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<rss version="2.0"><channel>'
echo "  <title>Updates for $SHARE_NAME</title>"
echo "  <link>http://nas.local/feeds/$SHARE_NAME.rss</link>"
echo "  <description>Incremental changes from $SHARE_NAME</description>"

while read -r file; do
    [ -z "$file" ] && continue
    FILE_PATH="$BASE_PATH/$file"
    GUID=$(sha256sum <<< "$file" | cut -d' ' -f1)
    echo "  <item>"
    echo "    <title>$file</title>"
    echo "    <link>file://$FILE_PATH</link>"
    echo "    <guid>$GUID</guid>"
    echo "    <pubDate>$(date -R)</pubDate>"
    echo "    <description>Detected change in $file</description>"
    echo "  </item>"
done < "$CHANGE_FILE"

echo '</channel></rss>'
