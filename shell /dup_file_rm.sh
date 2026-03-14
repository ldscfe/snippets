#!/bin/bash

HELP="""
NAME       : Duplicate file removal
DESCRIPTION:
  This script processes files in a specified directory (or the current directory).
  Files are sorted by size, only the first file with a unique MD5 hash is kept.

AUTHOR : Adam Lee(ldscfe@gmail.com)
DATE   : 2025-06-13

USAGE  : $0 [directory] [N=No details]
OPTIONS:
  -h, --help  : Display this help message.
  [directory] : The directory to process. If not provided, the current directory is used.
DEPENDENT  : md5sum, find, sort, stat
"""

# Show help if -h or --help is passed
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "$HELP"
  exit 0
fi

# Set working directory
if [ -n "$1" ] && [[ "$1" != "N" ]]; then
    directory="$1"
    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' not found." >&2    # stderr
        exit 1
    fi
else
    directory=$(pwd)
fi

# Initialize
TID=`date '+%Y/%m/%d %H:%M:%S'`
# ANSI Color
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'        # Color Reset

processed_files_count=0
deleted_files_count=0

# MD5 tracking
declare -A seen_md5

# Begin
while IFS= read -r line; do
  ((processed_files_count++))

  # Split size and path
  size="${line%% *}"
  file="${line#* }"

  # Compute MD5
  current_md5=$(md5sum "$file" | awk '{print $1}')

  # If MD5 not seen before, mark it; else delete
  if [[ -z "${seen_md5[$current_md5]}" ]]; then
    seen_md5["$current_md5"]=$size
    if [ "$2" != "N" ];then
      echo "File: $file, Size: $size, MD5: $current_md5"
    fi
  else
    if [[ "${seen_md5[$current_md5]}" == "$size" ]]; then
      rm -f "$file"

      ((deleted_files_count++))
      if [ "$2" != "N" ];then
        echo -e "${RED}Dele: $file, Size: $size, MD5: $current_md5${NC}"
      fi
    else
      if [ "$2" != "N" ];then
        echo -e "${YELLOW}Warning: MD5 collision (diff size) for '$file'. Retained. Size: $size, MD5: $current_md5${NC}"
      fi

    fi
  fi

done < <(find "$directory" -type f -exec stat --format="%s %n" {} + | sort -n)   # Collect files and sort by file size (ASC)

echo "[$TID] Finished processing Duplicate file removal. Total files processed: ${processed_files_count}, Total files deleted: ${deleted_files_count}."
