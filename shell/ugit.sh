#!/bin/bash

HELP='==============================================================================
Script Name:    ugit
Description:    Batch git operations (status/pull) for current user.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-04-29
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    ugit [status|pull]
    ugit -h | --help

Options:
    pull        Show status for all repos
    pull        Pull updates for all repos

Examples:
    ugit                # status
    ugit pull           # pull
==============================================================================
'

# --- Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# --- Path & Config ---
BASE_DIR="$PWD"
LPATH=(
    "acds"
    "rc-agent"
    "SRDS"
    "srds-web"
)

ACTION="status"
[[ "$1" == "pull" ]] && ACTION="pull"

echo -e "${BLUE}Action:${NC} ${GREEN}$ACTION${NC} | ${BLUE}User:${NC} ${CYAN}$(whoami)${NC}"

# --- Execution ---
for dir in "${LPATH[@]}"; do
    FULL_PATH="$BASE_DIR/$dir"

    echo "------------------------------------------------"
    if [ -d "$FULL_PATH" ]; then
        if [[ "$ACTION" == "status" ]]; then
            # Status
            echo -e "${CYAN}Checking:${NC} $dir"
            (cd "$FULL_PATH" && git status -s)
        else
            # Pull
            echo -e "${CYAN}Pulling:${NC} $dir"
            (cd "$FULL_PATH" && git pull) &> /dev/null

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Success: $dir${NC}"
            else
                echo -e "${RED}❌ Failed: $dir${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️ Directory not found: $FULL_PATH${NC}"
    fi
done
