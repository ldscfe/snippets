# ==============================================================================
# Script Name:   common.sh
# Description:   Common Constants and Utilities
# Author:        Adam Lee (ldscfe@gmail.com)
# Date:          2026-05-16
# Version:       1.1.0
# ==============================================================================

# --- Color Definitions (ANSI Escape Codes) ---
RED='\033[0;31m'          # ERROR / ALERT
GREEN='\033[0;32m'        # SUCCESS / DONE
YELLOW='\033[0;33m'       # HEADER / WARNING
BLUE='\033[0;34m'         # INFO
PURPLE='\033[0;35m'       # OPTIONAL / SPECIAL
CYAN='\033[0;36m'         # PATHS / USERS
LIGHT_GRAY='\033[0;37m'   # SECONDARY
DARK_GRAY='\033[1;30m'    # SKIP / ACTION / TRACE
NC='\033[0m'              # No Color (Reset)

# --- split line (default 60)
split_line() {
    local len=${1:-60}
    echo -ne "${BLUE}"
    printf '%*s\n' "$len" '' | tr ' ' '-'
    echo -ne "${NC}"
}

# --- Key-Value Argument Parser
# Usage: parse_kv_args "$@"
# Supports: key=value k2=v2... -> KEY=value K2=v2...
parse_kv_args() {
    for arg in "$@"; do
        if [[ "$arg" == *=* ]]; then
            local key="${arg%%=*}"
            local value="${arg#*=}"
            
            # xxx -> XXX
            local var_name=$(echo "$key" | tr '[:lower:]' '[:upper:]')
            
            eval "$var_name=\"$value\""
        fi
    done
}
