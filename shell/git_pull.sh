#!/bin/bash

HELP='==============================================================================
Script Name:    git_pull.sh
Description:    Batch update git repositories. Defaults to user "bi".
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-04-23
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    git_pull.sh [nouser]
    git_pull.sh -h | --help

Options:
    nouser      Execute git pull using the current user.

Examples:
    git_pull.sh
    git_pull.sh nouser
==============================================================================
'

# --- Colors & Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help & Validation ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# --- Path ---
BASE_DIR="$PWD"
LPATH=(
    "acds"
    "rc-agent"
    "SRDS"
    "srds-web"
)

# Determine execution mode
if [[ "$1" == "nouser" ]]; then
    EXEC_CMD=""
    USER_LABEL="Current User"
else
    EXEC_CMD="sudo -u bi -H"
    USER_LABEL="bi"
fi

# --- Execution ---
for dir in "${LPATH[@]}"; do
    FULL_PATH="$BASE_DIR/$dir"

    echo "------------------------------------------------"
    if [ -d "$FULL_PATH" ]; then
        echo -e "${CYAN}Updating: ${NC}$FULL_PATH ${BLUE}(User: $USER_LABEL)${NC}"
        
        # Execute git pull based on the selected mode
        if [ -z "$EXEC_CMD" ]; then
            (cd "$FULL_PATH" && git pull) &> /dev/null
        else
            $EXEC_CMD bash -c "cd '$FULL_PATH' && git pull" &> /dev/null
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Success: $dir${NC}"
        else
            echo -e "${RED}❌ Failed: $dir${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Directory not found: $FULL_PATH${NC}"
    fi
done
