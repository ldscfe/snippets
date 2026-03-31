#!/bin/bash

HELP='==============================================================================
Script Name:    search.sh
Description:    Enhanced grep wrapper for files, directories and wildcards.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-03-31
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    search.sh <search_term> [path/pattern] [context_lines]

Examples:
    search.sh "error" "~/log/" 2
    search.sh "info" "*2026*"
==============================================================================
'
# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"
# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -lt 1 ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# ----------
SEARCH_TERM=$1
INPUT_PATH=${2:-*}
CONTEXT=${3:-0}

# --- Path Processing ---
shopt -s nullglob
shopt -s dotglob

if [ ! -e "$INPUT_PATH" ]; then
    echo -e "${RED}[ERROR] Path does not exist: $INPUT_PATH\n${NC}"
    exit 1
fi

if [ -d "$INPUT_PATH" ]; then
    FILE_PATTERN="${INPUT_PATH%/ }/*"
else
    FILE_PATTERN="$INPUT_PATH"
fi

# --- Search Logic ---
FOUND_COUNT=0

for file in $FILE_PATTERN; do
    [ ! -f "$file" ] && continue

    if grep -qai "$SEARCH_TERM" "$file"; then
        let FOUND_COUNT++
        printf -v ID "%2d" "$FOUND_COUNT"

        echo -e "${BLUE}File: $file${NC}"
        echo -e "${DARK_GRAY}#${ID}---${file//?/-}${NC}"
        
        # macOS/Linux compatible grep arguments
        grep -i -n -a --color=always -C "$CONTEXT" "$SEARCH_TERM" "$file"
        
        echo -e "${NC}"
    fi
done

# --- Summary ---
if [ "$FOUND_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}[WARN] No matches found for: \"$SEARCH_TERM\"\n${NC}"
else
    echo -e "${GREEN}[INFO] Search completed! Found matches in $FOUND_COUNT file(s).\n${NC}"
fi
