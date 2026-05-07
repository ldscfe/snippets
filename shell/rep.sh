#!/bin/bash

HELP='==============================================================================
Script Name:    rep.sh
Description:    Recursively replace text in files, excluding the .git directory.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-07
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    rep.sh <search_string> <replace_string>
    rep.sh -h | --help

Examples:
    rep.sh "old_path/bin" "new_path/bin"
==============================================================================
'

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -ne 2 ]]; then
    echo -e "$HELP"
    exit 0
fi

# --- Variables ---
SEARCH=$1
REPLACE=$2

echo "Target:  '$SEARCH' -> '$REPLACE'"
echo "Status:  Processing files (skipping hidden directories)..."

# --- Execution ---
# Logic Breakdown:
# 1. find . -path "./.git" -prune: Identify the .git directory and exclude it from the search.
# 2. -o -type f: For all other paths, filter for regular files only.
# 3. -print0 | xargs -0: Use null delimiters to safely handle filenames with spaces or quotes.
# 4. perl -i -pe: Perform in-place editing using Perl's powerful regex engine.
# 5. "s/\Q$SEARCH\E/$REPLACE/g": 
#    - \Q...\E: Treats everything inside as literal text (escapes characters like '.' and '/').

find . -path "./.git" -prune -o -type f -print0 | xargs -0 perl -i -pe "s/\Q$SEARCH\E/$REPLACE/g"

if [ $? -eq 0 ]; then
    echo "Success."
else
    echo "Error."
fi
