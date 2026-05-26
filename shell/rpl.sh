#!/bin/bash

HELP='==============================================================================
Script Name:    rpl.sh
Description:    Batch replace literal strings in files with preview and confirmation.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-26
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    rpl.sh <search_string> <replace_string>
    rpl.sh -h | --help

Examples:
    rpl.sh "old_api_url" "new_api_url"
==============================================================================
'

# --- Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -ne 2 ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

SEARCH=$1
REPLACE=$2

split_line
echo -e "Search:  ${CYAN}'$SEARCH'${NC}"
echo -e "Replace: ${GREEN}'$REPLACE'${NC}"
split_line
echo -e "${BLUE}Scanning files and calculating matches...${NC}"

# Create a temporary file to store matched files
MATCH_LIST=$(mktemp)

# 1. Scan and filter files that actually contain the search string
find . \( -name ".git" -o -name "dist" -o -name "__pycache__" -o -name "node_modules" -o -name "target" \) -prune -o -type f -print0 | \
    xargs -0 grep -lF "$SEARCH" > "$MATCH_LIST" 2>/dev/null

# Count the number of matched files
FILE_COUNT=$(wc -l < "$MATCH_LIST" | tr -d ' ')

# 2. Validation and Preview
if [ "$FILE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Everything is up-to-date. No matches found.${NC}"
    rm -f "$MATCH_LIST"
    exit 0
fi

split_line
echo -e "Found ${YELLOW}$FILE_COUNT${NC} file(s) containing '$SEARCH':"
cat "$MATCH_LIST"
split_line

# 3. User Confirmation
read -p "$(echo -e "${YELLOW}Are you sure you want to proceed with the replacement? (y/N): ${NC}")" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Replacement cancelled by user.${NC}"
    rm -f "$MATCH_LIST"
    exit 0
fi

# 4. Execute Perl Literal Replacement
echo -e "${BLUE}Processing replacements...${NC}"
xargs perl -i -pe "s/\Q$SEARCH\E/$REPLACE/g" < "$MATCH_LIST"

# Check exit status
if [ $? -eq 0 ]; then
    split_line
    echo -e "${GREEN}Success: $FILE_COUNT file(s) modified.${NC}"
else
    split_line
    echo -e "${RED}Error: Replacement failed.${NC}"
fi

# Clean up temporary file
rm -f "$MATCH_LIST"
