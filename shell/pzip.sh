#!/bin/bash

# ==============================================================================
# Script Name:    pzip.sh
# Description:    Project Archiver with Dynamic Filtering (Append/Replace mode).
# Author:         Adam Lee (ldscfe@gmail.com)
# Date:           2026-03-19
# Version:        1.0.0
# License:        MIT
#
# Usage:
#   pzip [src_dir] [zip_name] [mode]
#
# Examples:
#   pzip . backup             : Use default filters (target, .git, etc.)
#   pzip . backup +tmp|logs   : Default filters + append tmp and logs
#   pzip . backup "src|docs"  : Filter only src and docs (replace mode)
# ==============================================================================

# --- 1. Parameter Initialization ---
src_dir="${1:-.}"
zip_name=""
if [ "$src_dir" = "." ]; then
    zip_name="${2:-archive}.zip"
else
    zip_name="${2:-${src_dir%/}}.zip"
fi
mode="$3"

# --- 2. Filter Rule Logic ---
default_ignore="*.DS_Store|__MACOSX/*|*/.git/*|*/.idea/*|*/.vscode/*|*/__pycache__/*|*/target/*|*/node_modules/*"
ignore_pattern=""

if [[ -z "$mode" ]]; then
    # Default mode
    ignore_pattern="$default_ignore"
elif [[ "$mode" == +* ]]; then
    # Append mode: remove '+' prefix and merge with defaults
    ignore_pattern="${default_ignore}|${mode#+}"
else
    # Replace mode: use user-defined pattern entirely
    ignore_pattern="$mode"
fi

# --- 3. Convert Pattern to zip argument array ---
# Convert "A|B|C" to (-x "A" -x "B" -x "C")
IFS='|' read -r -a ignore_array <<< "$ignore_pattern"
exclude_args=()
for item in "${ignore_array[@]}"; do
    exclude_args+=("-x" "$item")
done

# --- 4. Execute Compression ---
echo "Compressing: $src_dir -> $zip_name"
echo "Filter mode: ${mode:-DEFAULT}"

zip -o -r "$zip_name" "$src_dir" "${exclude_args[@]}"

# --- 5. Result Feedback ---
if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "Successfully created: $zip_name"
    echo "Included filter rules: $ignore_pattern"
    echo "------------------------------------------------"
else
    echo "Error: Compression failed" >&2
    exit 1
fi
