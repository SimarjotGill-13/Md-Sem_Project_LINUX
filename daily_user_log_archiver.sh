#!/bin/bash

set -euo pipefail

LOG_DIR="$HOME/daily_logs"
ARCHIVE_DIR="$LOG_DIR/archive"
MONTHLY_SUMMARY="$LOG_DIR/monthly_summary.txt"

mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"
touch "$MONTHLY_SUMMARY"

NOW=$(date +'%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/log_$NOW.txt"

# ---- Create today's log ----
{
  echo "Daily log: $NOW"
  echo "User: ${USER:-$(whoami)}"
  echo "Date: $(date)"
  echo "Uptime:"
  uptime
  echo "--- Top Processes ---"
  ps aux | sort -nrk 3 | head -n 6
  echo "----------------------"
} >> "$LOG_FILE"

# ---- Move .txt logs older than 7 days to archive ----
find "$LOG_DIR" \
  -type d -name "$(basename "$ARCHIVE_DIR")" -prune -o \
  -type f -name "log_*.txt" -mtime +7 -exec mv -n {} "$ARCHIVE_DIR" \;

# ---- Compress archived .txt files (only if any exist) ----
if ls "$ARCHIVE_DIR"/*.txt >/dev/null 2>&1; then
    TARFILE="$ARCHIVE_DIR/archive_$(date +%Y-%m-%d).tar.gz"
    ( cd "$ARCHIVE_DIR" && tar -czf "$(basename "$TARFILE")" -- *.txt )
    rm "$ARCHIVE_DIR"/*.txt
fi

# ---- Update summary ----
echo "[$(date)] Created: $LOG_FILE" >> "$MONTHLY_SUMMARY"

echo "Done. Log saved at: $LOG_FILE"
exit 0
