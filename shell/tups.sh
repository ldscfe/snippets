#!/bin/bash

HELP='==============================================================================
Script Name:    tups.sh
Description:    Tmux Up Service - A lightweight, YAML-configured service manager.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-22
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Dependencies:   This script requires "yq" and "tmux" to be installed.
                - macOS : brew install yq tmux
                - Ubuntu: sudo snap install yq tmux
                - Other:  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
                          chmod +x /usr/local/bin/yq

# Config
  ~/bin/tups.sh
  ~/bin/tups.yaml

# tups.yaml
  claude:
    name: "Claude"
    cwd: "$HOME/"
    cmd: "fcc-server"

  rc-agent:
    name: "rc-agent"
    cwd: "$HOME/Documents/github/rc-agent"
    cmd: "RUST_LOG=info ../rust_target/release/rc-agent"

# Usage
  tups <service_name>
  tups -h | --help

# Examples
  tups claude      # Start the Claude server
  tups rc-agent    # Start the rc-agent server

==============================================================================
'

# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$#" -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

set -euo pipefail

# --- Environment & Tool Check ---
CONFIG_FILE="$HOME/bin/tups.yaml"
SERVICE_KEY="$1"

if ! command -v yq &> /dev/null; then
    echo -e "${RED}Error: 'yq is required but not installed.${NC}"
    echo -e "${DARK_GRAY}Please install it via: brew install yq${NC}"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

# --- Parse YAML via yq ---
# Check if service exists in YAML
EXISTS=$(yq ".services | has(\"$SERVICE_KEY\")" "$CONFIG_FILE")
if [[ "$EXISTS" != "true" ]]; then
    echo -e "${RED}Error: Service '$SERVICE_KEY' is not defined in YAML.${NC}"
    echo -e "${YELLOW}Available services:${NC}"
    yq '.services | keys | .[]' "$CONFIG_FILE" | sed 's/^/  - /'
    exit 1
fi

# Read values (and evaluate environment variables like $HOME in paths)
SESSION_NAME=$(yq ".services.$SERVICE_KEY.name" "$CONFIG_FILE")
RAW_CWD=$(yq ".services.$SERVICE_KEY.cwd" "$CONFIG_FILE")
TARGET_DIR=$(eval echo "$RAW_CWD")
RUN_CMD=$(yq ".services.$SERVICE_KEY.cmd" "$CONFIG_FILE")

# --- Main Logic ---

# 1. Navigate to directory
if [[ -d "$TARGET_DIR" ]]; then
    echo -e "${BLUE}[$SERVICE_KEY]${NC} Changing directory to: ${CYAN}$TARGET_DIR${NC}"
    cd "$TARGET_DIR"
else
    echo -e "${RED}Error: Directory not found -> $TARGET_DIR${NC}"
    exit 1
fi

# 2. Restart Capability: Kill old session if active
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}[$SERVICE_KEY] Existing session '$SESSION_NAME' found. Restarting...${NC}"
    tmux kill-session -t "$SESSION_NAME"
    sleep 0.5
fi

# 3. Boot service in Tmux
echo -e "${BLUE}[$SERVICE_KEY]${NC} Launching inside tmux session: ${PURPLE}$SESSION_NAME${NC}"

# Start detached and attach terminal fallback
tmux new-session -d -s "$SESSION_NAME" "$RUN_CMD ; exec bash"

# 4. Double-check status
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${GREEN}--------------------------------------------------${NC}"
    echo -e "${GREEN}Success: $SERVICE_KEY is now running background.${NC}"
    echo -e "View logs: ${CYAN}tmux a -t $SESSION_NAME${NC}"
    echo -e "${GREEN}--------------------------------------------------${NC}"
else
    echo -e "${RED}Error: tmux failed to initialize session for $SERVICE_KEY.${NC}"
    exit 1
fi
