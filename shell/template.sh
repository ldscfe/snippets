#!/bin/bash

HELP='==============================================================================
Script Name:    template.sh
Description:    Template script for creating standardized shell scripts.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-04-01
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    template.sh [options] [arguments]

Examples:
    template.sh -h
    template.sh --help
==============================================================================
'
# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"
# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -lt 1 ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

# ----------
# --- Variables ---
SCRIPT_DIR="$(cd ""$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# --- Function: Print Info ---
print_info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

# --- Function: Print Error ---
print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# --- Function: Print Warning ---
print_warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

# --- Main Logic ---
main() {
    print_info "Script started: $SCRIPT_NAME"
    
    # Add your logic here
    
    print_info "Script completed successfully!"
}

# --- Execute ---
main "$@"