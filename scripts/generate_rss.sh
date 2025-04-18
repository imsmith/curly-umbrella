#!/bin/bash
# Args: music /mnt/music changed.txt

SHARE_NAME="$1"
BASE_PATH="$2"
CHANGES="$3"

echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<rss version="2.0"><channel>'
echo "  <title>Updates for $SHARE_NAME</title>"
echo "  <link>http://nas.local/feeds/$SHARE_NAME.rss</link>"
echo "  <description>Changes detected in $SHARE_NAME share</description>"

while read -r file; do
  [[ -z "$file" ]] && continue
  FILE_PATH="$BASE_PATH/$file"
  GUID=$(sha256sum <<< "$file" | cut -d' ' -f1)
  echo "  <item>"
  echo "    <title>$file</title>"
  echo "    <link>file://$FILE_PATH</link>"
  echo "    <guid>$GUID</guid>"
  echo "    <pubDate>$(date -R)</pubDate>"
  echo "    <description>Detected change in $file</description>"
  echo "  </item>"
done < "$CHANGES"

echo '</channel></rss>'
