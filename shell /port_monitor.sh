#!/bin/bash

# ==============================================================================
# Script Name:   port_monitor.sh
# Description:   Multi-port monitoring and auto-restart service script.
# Author:        Adam Lee(ldscfe@gmail.com)
# Date:          2026-01-15
# Version:       1.0.0
# License:       MIT
# Compatibility: macOS (BSD), Linux (GNU)
#
# Sub-script Example:
#   port_monitor_1080.sh : ssh -f -N -D 1080 -C bi@mc2.kr
#   port_monitor_23389.sh: ssh -f -N -L 23389:127.0.0.1:3389 -C bi@mc2.kr
# ==============================================================================

# --- Configuration ---
# Target ports to monitor
PORTS=(1080 23389)

# Dedicated directory for startup scripts
SCRIPT_DIR="$HOME/scripts/monitor"

# Path to the unified log file
LOG_FILE="$HOME/logs/port_monitor.log"

# --- Initialization ---
mkdir -p "$(dirname "$LOG_FILE")"

# --- Global Parameter Check ---
# Check if "FILE" argument is passed to the script for silent logging
DO_LOG_FILE=false
for arg in "$@"; do
    [ "$arg" == "FILE" ] && DO_LOG_FILE=true
done

# --- Color Definitions (Cross-platform) ---
RED='\033[0;31m'             # Error
GREEN='\033[0;32m'           # SUCCESS
YELLOW='\033[0;33m'
GRAY='\033[0;37m'            # 
DARK_GRAY='\033[1;30m'       # ACTION
NC='\033[0m'                 # No Color

# --- Unified Log Function ---
log() {
    local msg="$1"
    local level="${2:-INFO}"
    local color=$NC

    case "$level" in
        "ACTION")  color=$DARK_GRAY ;;
        "ERROR")   color=$RED       ;;
        "SUCCESS") color=$GREEN     ;;
        *)         color=$NC        ;;
    esac

    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [ "$DO_LOG_FILE" = true ]; then
        # Silent Mode: Formatted text to log file
        printf "%s: [%s] %s\n" "$timestamp" "$level" "$msg" >> "$LOG_FILE"
    fi
    # Interactive Mode: Colored output to terminal
    printf "%b%s: [%s] %s%b\n" "$color" "$timestamp" "$level" "$msg" "$NC"
}

# --- Main Monitoring Loop ---
for PORT in "${PORTS[@]}"; do
    CMD="$SCRIPT_DIR/port_monitor_${PORT}.sh"
    
    # Check if the port is active using lsof
    if ! lsof -nP -iTCP:$PORT -sTCP:LISTEN > /dev/null; then
        
        log "Port $PORT is inactive." "ACTION"
        
        if [ -f "$CMD" ]; then
            # Capture combined output of the startup script
            output=$(/bin/bash "$CMD" 2>&1)

            # Check exit status immediately after command execution
            if [ $? -eq 0 ]; then
                log "Port $PORT started. ${output:+ Info: $output}" "SUCCESS"
            else
                log "Port $PORT failed. ${output:+ Error: $output}" "ERROR"
            fi
        else
            log "Port $PORT: $CMD not found." "ERROR"
        fi
    else
        # Optional: log "Port $PORT is active."
        : 
    fi
done
