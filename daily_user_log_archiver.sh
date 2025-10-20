#!/bin/bash
# Daily User Log Archiver

LOG_DIR="$HOME/daily_logs"
ARCHIVE_DIR="$LOG_DIR/archive"
TODAY_FILENAME="log_$(date +%Y-%m-%d).txt"
LOG_FILE="$LOG_DIR/$TODAY_FILENAME"
WEEKLY_ARCHIVE="$ARCHIVE_DIR/weekly_logs_$(date +%Y-%m-%d).tar.gz"

# create directories if missing
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" || { echo "ERROR: can't create $LOG_DIR"; exit 1; }
fi
if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR" || { echo "ERROR: can't create $ARCHIVE_DIR"; exit 1; }
fi

# create or update today's log file
touch "$LOG_FILE" || { echo "ERROR: cannot create $LOG_FILE"; exit 1; }

# collect info and write into log
{
  echo "=========================================="
  echo "         DAILY USER LOG ARCHIVER"
  echo "=========================================="
  echo "Date: $(date)"
  echo "User: $(whoami)"
  # macOS 'uptime' doesn't support -p, so use plain uptime
  echo "Uptime: $(uptime)"
  echo
  echo "----- Logged in users (who) -----"
  who || true
  echo
  echo "----- Top 5 CPU-consuming processes -----"
  # macOS friendly ps: use -A or -ax to list all processes
  ps -axo pid,comm,%mem,%cpu | head -n 6 || true
  echo
  echo "----- Disk Usage (df -h) -----"
  df -h || true
  echo
  echo "----- Memory Info -----"
  # macOS doesn't have free, use vm_stat
  if command -v free >/dev/null 2>&1; then
    free -h || true
  else
    vm_stat || true
  fi
  echo "=========================================="
} > "$LOG_FILE"

# make sure file has content
if [ ! -s "$LOG_FILE" ]; then
  echo "ERROR: $LOG_FILE is empty or not written."
  exit 1
fi

echo "Log file created: $LOG_FILE"

# move logs older than 7 days to archive
find "$LOG_DIR" -maxdepth 1 -type f -name "log_*.txt" -mtime +7 -exec mv {} "$ARCHIVE_DIR" \; 2>/dev/null || true

# compress archived logs if any
if ls "$ARCHIVE_DIR"/*.txt >/dev/null 2>&1; then
  tar -czf "$WEEKLY_ARCHIVE" -C "$ARCHIVE_DIR" -- *.txt 2>/dev/null || true
  # remove text logs after successful archive (if tar created file)
  [ -f "$WEEKLY_ARCHIVE" ] && rm -f "$ARCHIVE_DIR"/*.txt 2>/dev/null || true
fi

# cleanup old archives
find "$ARCHIVE_DIR" -type f -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true

echo "Daily User Log Archiver run completed."
# === Copy latest log to project folder ===
PROJECT_DIR="$HOME/Daily-User-Log-Archiver"
if [ -f "$LOG_FILE" ]; then
    cp "$LOG_FILE" "$PROJECT_DIR"/ 2>/dev/null
    echo "Copied latest log file to project folder: $PROJECT_DIR"
else
    echo " Log file not found to copy!"
fi
