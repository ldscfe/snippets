#!/bin/bash

HELP='==============================================================================
Script Name:    usync.sh
Description:    Sync current directory to an exact target directory with confirmation.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-16
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    usync.sh target=/path/to/target [del=YES]
    usync.sh -h | --help

Examples:
    usync.sh target=/Users/adamlee/Documents/github/rc-agent/.AI
    usync.sh target=/Users/adamlee/Documents/github/rc-agent del=YES
==============================================================================
'

# --- Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -lt 1 ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# --- Parse Arguments ---
TARGET=""
DEL_MODE=false
RSYNC_OPTS="-avc"

parse_kv_args "$@"

# Validate Target
if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: target directory is required (e.g., target=/path/to/dir)${NC}"
    exit 1
fi

# --- Build rsync Options ---
split_line
if [ "$DEL_MODE" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --delete"
    echo -e "Mode:   ${YELLOW}[FULL SYNC]${NC} - '--delete' is ENABLED."
else
    echo -e "Mode:   ${GREEN}[INCREMENTAL SYNC]${NC} - Files in target won't be deleted."
fi

echo -e "Source: ${CYAN}'$(pwd)/'${NC}"
echo -e "Target: ${CYAN}'$TARGET'${NC}"
split_line
echo -e "${BLUE}Running dry-run to calculate changes...${NC}"

# --- 1. Dry Run & Capture Output ---
DRY_RUN_LOG=$(mktemp)
rsync $RSYNC_OPTS --dry-run . "$TARGET" > "$DRY_RUN_LOG"

# Display the dry-run output
cat "$DRY_RUN_LOG"
split_line

# --- 2. Count Real Changes ---
# Filter out rsync metadata and directories to count actual files
FILE_COUNT=$(grep -E -v '(building file list|bytes/sec|total size|speedup|^$)' "$DRY_RUN_LOG" | grep -v '/$' | wc -l | tr -d ' ')

rm -f "$DRY_RUN_LOG"

# --- 3. Verification Logic ---
if [ "$FILE_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}Summary: Found ${GREEN}$FILE_COUNT${YELLOW} file(s) to be synchronized."
fi

read -p "$(echo -e "${YELLOW}Are you sure you want to proceed with the actual synchronization? (y/N): ${NC}")" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Sync cancelled by user.${NC}"
    exit 0
fi

# --- 4. Actual Execution ---
echo -e "${BLUE}Starting actual synchronization...${NC}"
rsync $RSYNC_OPTS . "$TARGET"

if [ $? -eq 0 ]; then
    split_line
    echo -e "${GREEN}Success: Sync complete.${NC}"
else
    split_line
    echo -e "${YELLOW}Error: Sync failed.${NC}"
fi
