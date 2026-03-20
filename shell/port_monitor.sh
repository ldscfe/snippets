# ==============================================================================
# Script Name:   port_monitor.sh
# Description:   Multi-port SSH tunnel monitoring and auto-restart service.
# Author:        Adam Lee (ldscfe@gmail.com)
# Date:          2026-03-20
# Version:       1.2.0
# License:       MIT
# Compatibility: macOS (BSD), Linux (GNU)
#
# Usage:
#   bash port_monitor.sh
# ==============================================================================

#!/bin/bash

# Load common
COMMON_LIB="$HOME/bin/common.sh"
if [ -f "$COMMON_LIB" ]; then
    source "$COMMON_LIB"
fi

# --- Configuration Section ---
# Format: "PORT:COMMAND"
CMD=(
    "1080:ssh -f -N -D 1080 -C bi@mc2.kr"
    "23389:ssh -f -N -L 23389:127.0.0.1:3389 -C bi@mc2.kr"
)

# --- Function to Start/Monitor Port ---
monitor_port() {
    local port=$1
    local command=$2

    if [ -z "$command" ]; then
        echo -e "${RED}[ERROR] No command defined for port $port${NC}"
        return 1
    fi

    # Check if the port is already listening (macOS/Linux compatible)
    if lsof -Pi :"$port" -sTCP:LISTEN -t >/dev/null; then
        echo -e "${DARK_GRAY}[SKIP] Port $port is already active.${NC}"
    else
        echo -e "${BLUE}[START] Launching tunnel for port $port...${NC}"
        # Execute the command
        eval "$command"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[SUCCESS] Port $port is now monitored.${NC}"
        else
            echo -e "${RED}[FAILED] Could not start tunnel for port $port.${NC}"
        fi
    fi
}

# --- Main ---
for item in "${CMD[@]}"; do
    # Parameter expansion to split key and value
    port="${item%%:*}"
    cmd="${item#*:}"
    
    monitor_port "$port" "$cmd"
done
