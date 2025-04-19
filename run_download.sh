#!/bin/bash

# Default values
BBOX=""
MAXZOOM=""
MAP_FILE="map.pmtiles"
DATA_DIR="data"
PMTILES_IMAGE_VERSION="v1.27.2"

# Load .env if it exists (as fallback)
if [ -f ".env" ]; then
  set -o allexport
  source .env
  set +o allexport
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --bbox) BBOX="$2"; shift ;;
    --maxzoom) MAXZOOM="$2"; shift ;;
    --map-file) MAP_FILE="$2"; shift ;;
    --data-dir) DATA_DIR="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Use env variables as fallback
BBOX="${BBOX:-$BBOX}"
MAXZOOM="${MAXZOOM:-$MAXZOOM}"
MAP_FILE="${MAP_FILE:-$MAP_FILE}"
DATA_DIR="${DATA_DIR:-data}"

# Ensure data dir exists
mkdir -p "$DATA_DIR"

# Get yesterday's date in YYYYMMDD format (macOS/Linux compatible)
if date --version >/dev/null 2>&1; then
  # GNU date
  YESTERDAY=$(date -d "yesterday" +%Y%m%d)
else
  # BSD/macOS date
  YESTERDAY=$(date -v-1d +%Y%m%d)
fi

# Build download URL
URL="https://build.protomaps.com/${YESTERDAY}.pmtiles"

# Set bbox and maxzoom options if provided
BBOX_OPTION=""
if [ -n "$BBOX" ]; then
  BBOX_OPTION="--bbox=$BBOX"
fi

MAXZOOM_OPTION=""
if [ -n "$MAXZOOM" ]; then
  MAXZOOM_OPTION="--maxzoom=$MAXZOOM"
fi

# Define the temporary file path inside container
TMP_FILE="/data/${MAP_FILE}.tmp"

# Run Docker command with versioned image
docker run -it \
  -v "$(realpath "$DATA_DIR"):/data/" \
  "protomaps/go-pmtiles:${PMTILES_IMAGE_VERSION}" \
  extract "$URL" "$TMP_FILE" $BBOX_OPTION $MAXZOOM_OPTION

# Finalize the map file if successful
if [ -f "$DATA_DIR/${MAP_FILE}.tmp" ]; then
  if [ -f "$DATA_DIR/$MAP_FILE" ]; then
    rm "$DATA_DIR/$MAP_FILE"
  fi
  mv "$DATA_DIR/${MAP_FILE}.tmp" "$DATA_DIR/$MAP_FILE"
else
  echo "Error: Download failed. Temporary file not found."
  exit 1
fi
