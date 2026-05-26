#!/bin/bash

HELP='==============================================================================
Script Name:    usync.sh
Description:    Sync current directory to an exact target directory with confirmation.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-26
Version:        1.2.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    usync.sh target=/path/to/target [del=YES]
    usync.sh target=rc-agent [del=YES]       (Auto-completes based on LPATH)
    usync.sh -h | --help

Examples:
    usync.sh target=rc-agent
    usync.sh target=rc-agent del=YES
    usync.sh target=/Users/adamlee/Documents/github/rc-agent/.AI

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
LPATH="/Users/adamlee/Documents/github"
SOURCE="${LPATH}/ALDS/.AI/"
TARGET=""
RSYNC_OPTS="-avcO"

parse_kv_args "$@"

if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: target directory is required (e.g., target=/path/to/dir)${NC}"
    exit 1
fi

if [[ "$TARGET" != /* ]]; then
    TARGET="${LPATH}/${TARGET}/.AI"
fi

TARGET="${TARGET%/}"

if [ ! -d "$TARGET" ]; then
    echo -e "${RED}Error: Target directory '$TARGET' does not exist.${NC}"
    exit 1
fi

if [ "$SOURCE" = "${TARGET}/" ] || [ "$SOURCE" = "$TARGET" ]; then
    echo -e "${RED}Error: Source and Target are the same directory ($SOURCE). Sync aborted.${NC}"
    exit 1
fi

# --- Build Options ---
split_line

if [ "$DEL" = "YES" ]; then
    RSYNC_OPTS="$RSYNC_OPTS --delete"
    echo -e "Mode:   ${YELLOW}[FULL SYNC]${NC} - '--delete' is ENABLED."
else
    echo -e "Mode:   ${GREEN}[INCREMENTAL SYNC]${NC} - Files in target won't be deleted."
fi

echo -e "Source: ${CYAN}'$SOURCE'${NC}"
echo -e "Target: ${CYAN}'$TARGET'${NC}"

split_line

echo -e "${BLUE}Running dry-run to calculate changes...${NC}"

# --- 1. Dry Run ---
DRY_RUN_LOG=$(mktemp)
rsync $RSYNC_OPTS --dry-run $SOURCE "$TARGET" > "$DRY_RUN_LOG"

# --- 2. Count Changes ---
FILE_COUNT=$(grep -v '/$' "$DRY_RUN_LOG" | grep -v 'building file list' | grep -v 'deleting' | grep -E -v '(bytes/sec|total size|speedup|^$)' | wc -l | tr -d ' ')

# --- 3. Verification ---
if [ "$FILE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Everything is up-to-date. No synchronization needed.${NC}"
    rm -f "$DRY_RUN_LOG"
    exit 0
fi

cat "$DRY_RUN_LOG"
rm -f "$DRY_RUN_LOG"

split_line

if [ "$FILE_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}Summary: Found ${GREEN}$FILE_COUNT${YELLOW} file(s) to be synchronized.${NC}"
else
    echo -e "${GREEN}Summary: Found $FILE_COUNT file(s) to be synchronized.${NC}"
fi

read -p "$(echo -e "${YELLOW}Are you sure you want to proceed with the actual synchronization? (y/N): ${NC}")" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Sync cancelled by user.${NC}"
    exit 0
fi

# --- 4. Execution ---
echo -e "${BLUE}Starting actual synchronization...${NC}"
rsync $RSYNC_OPTS $SOURCE "$TARGET"

if [ $? -eq 0 ]; then
    split_line
    echo -e "${GREEN}Success: Sync complete.${NC}"
else
    split_line
    echo -e "${RED}Error: Sync failed.${NC}"
fi
