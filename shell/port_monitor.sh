#!/bin/bash

# Configuration section
# Define ports and their corresponding commands in the format 'port: command'

# Example Configuration:
# 1080: ssh -f -N -D 1080 -C bi@mc2.kr

declare -A commands
commands["1080"]="ssh -f -N -D 1080 -C bi@mc2.kr"

# Color definitions for logging
RED='[31m'
GREEN='[32m'
YELLOW='[33m'
RESET='[0m'

# Function to start monitoring for a port
monitor_port() {
    local port=$1
    local command=${commands[$port]}

    if [ -z "$command" ]; then
        echo -e "${RED}No command defined for port $port${RESET}"
        return 1
    fi

    echo -e "${GREEN}Monitoring port $port with command: $command${RESET}"
    # Here you can add the monitoring logic as required
    # For example:
    eval "$command &"
}

# Main script logic
for port in "${!commands[@]}"; do
    monitor_port "$port"
done
