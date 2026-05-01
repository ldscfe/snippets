#!/bin/bash

HELP='==============================================================================
Script Name:    start_claude.sh
Description:    Starts or restarts the Claude server in a detached screen session.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-01
Version:        1.1.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    start_claude.sh [options]

Options:
    -h, --help    Show this help message.

Examples:
    ./start_claude.sh
==============================================================================
'

# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# --- Configuration ---
TARGET_DIR="/Users/ldscf/Documents/claude/free-claude-code"
SESSION_NAME="Claude"
HOST="127.0.0.1"
PORT="18082"

# 1. Navigate to the project directory
echo -e "${BLUE}Changing directory to:${NC} ${CYAN}$TARGET_DIR${NC}"
cd "$TARGET_DIR" || { echo -e "${RED}Error: Directory not found.${NC}"; exit 1; }

# 2. Kill existing session if it exists (Restart Capability)
if screen -list | grep -q "\.$SESSION_NAME"; then
    echo -e "${YELLOW}Existing session '$SESSION_NAME' found. Restarting...${NC}"
    screen -S "$SESSION_NAME" -X quit
    sleep 1 # Wait for port release
fi

# 3. Start the server
echo -e "${BLUE}Starting Uvicorn server in screen session:${NC} ${PURPLE}$SESSION_NAME${NC}"

# uv run
screen -dmS "$SESSION_NAME" bash -c "uv run uvicorn server:app --host $HOST --port $PORT; exec bash"

# 4. Confirmation output
if [ $? -eq 0 ]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}Success: Service started/restarted successfully.${NC}"
    echo -e "View logs: ${CYAN}screen -r $SESSION_NAME${NC}"
    echo -e "${GREEN}================================================${NC}"
else
    echo -e "${RED}Error: Failed to start the screen session.${NC}"
    exit 1
fi
