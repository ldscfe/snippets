#!/bin/bash
# ==============================================================================
# Script Name:   tls.sh
# Description:   Project Structure Viewer with Conservative Engineering filters.
# Author:        Adam Lee (ldscfe@gmail.com)
# Date:          2026-03-19
# Version:       1.0.0
# License:       MIT
# Compatibility: macOS (BSD), Linux (GNU)
#
# Usage:
#   tls [depth] [path] [+pattern|pattern]
#
# Examples:
#   tls 4 docai              : 'docai' directory, default filter (target, dist, .*, etc.)
#   tls 4 . +tmp|logs        : filter + 'tmp' and 'logs'
#   tls 2 . "src|docs"       : ONLY filter 'src' and 'docs'
#
# Setup (~/.zshrc or ~/.bashrc):
#   alias tls='bash ~/bin/tls.sh'
# ==============================================================================

tls() {
    local depth="${1:-4}"
    local target_path="${2:-.}"
    local mode="$3"
    
    # Default filter
    local default_ignore='dist|target|src/test|.*|node_modules|__pycache__'
    local ignore=""

    if [[ -z "$mode" ]]; then
        # Use default base filters
        ignore="$default_ignore"
    elif [[ "$mode" == +* ]]; then
        # Append mode: Remove '+' prefix and add to default_ignore
        ignore="${default_ignore}|${mode#+}"
    else
        # Replace mode: Use user-provided pattern entirely
        ignore="$mode"
    fi

    # Execute tree with directory-first sorting and file indicators
    # -L: Depth | -I: Ignore pattern | -F: Append indicators (*/=>@|)
    tree --dirsfirst -F \
         -L "$depth" \
         -I "$ignore" \
         "$target_path"
}

# Execute function if the script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    tls "$@"
fi
