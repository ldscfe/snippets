#!/bin/bash

HELP='==============================================================================
Script Name:    snip.sh
Description:    Update local scripts from GitHub snippets repository.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-08
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    snip.sh <file_name> [Y/N] [git_path]
    snip.sh -h | --help

Examples:
    snip.sh ugit.sh        # Compare local ugit.sh with remote and ask to update
==============================================================================
'

# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$#" -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# set -euo pipefail

# --- Constants ---
BASE_URL="https://raw.githubusercontent.com/ldscfe/snippets/main/shell"

FILE_NAME="${1:-}"
FORCE_UPDATE="${2:-N}"
REMOTE_PATH="${3:-$FILE_NAME}"

LOCAL_PATH="$FILE_NAME"
REMOTE_URL="$BASE_URL/$REMOTE_PATH"
TEMP_FILE="$(mktemp)"

cleanup() {
    [[ -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
}

trap cleanup EXIT

echo -e "${BLUE}Checking: ${REMOTE_URL}${NC}"

if ! curl -fsSL --connect-timeout 5 --max-time 15 "$REMOTE_URL" -o "$TEMP_FILE"; then
    exit 1
fi

# file not exist, save +x
if [[ ! -f "$LOCAL_PATH" ]]; then
    cp "$TEMP_FILE" "$LOCAL_PATH"
    chmod +x "$LOCAL_PATH"

    echo -e "🚀 ${GREEN}Installed: ${LOCAL_PATH}${NC}"
    exit 0
fi

# file exist, same
if diff -q "$LOCAL_PATH" "$TEMP_FILE" >/dev/null; then
    echo -e "   ${BLUE}➜  No changes.${NC}"
    exit 0
fi

# file exist, update
perform_update() {
    cp "$TEMP_FILE" "$LOCAL_PATH"
    chmod +x "$LOCAL_PATH"

    echo -e "🚀 ${GREEN}Updated: $LOCAL_PATH${NC}"
}

if [[ "$FORCE_UPDATE" == "Y" || "$FORCE_UPDATE" == "y" ]]; then
    perform_update
    exit 0
fi

read -r -p "Update $FILE_NAME ? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    perform_update
else
    echo -e "⚠️ ${YELLOW}Canceled.${NC}"
fi
