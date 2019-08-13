#!/bin/bash

# Wait until Finder is started.
  FINDER_PROCESS=$(pgrep -l "Finder")
  until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >> "$TMP_DEBUG_LOG"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
  done
