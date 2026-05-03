#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

TIMESTAMP=$(grep '"doc_update_time"' config/timestamps.json | cut -d'"' -f4)
echo "Target timestamp: $TIMESTAMP"

find . -name "*.md" -type f | while read -r file; do
  if grep -q 'Document Update Time\|文档更新时间' "$file"; then
    echo "Updating: $file"
    sed -i '' "s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}/$TIMESTAMP/g" "$file"
  fi
done
echo "Done!"