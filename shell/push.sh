#!/bin/bash

HELP='==============================================================================
Script Name:    push.sh
Description:    Automated Git status, commit, and push script.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-08
Version:        1.1.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    push.sh <project_dir> [commit_message]
    push.sh -h | --help

Arguments:
    project_dir       Local path of the Git project (required).
    commit_message    Custom commit message (optional).

Examples:
    push.sh .                          # Push current dir with default message
    push.sh ~/repo "feat: update ui"   # Push specific repo with custom message
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

PROJECT_DIR="${1:-}"
COMMIT_MSG="${2:-"chore: auto update by script $(date +'%Y-%m-%d %H:%M:%S')"}"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo -e "${RED}[ERROR] Directory does not exist: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Not a Git repository: $PROJECT_DIR${NC}"
    exit 1
fi

# -------- Git Status --------
echo "================================================="
echo "📦 Project: $(pwd)"
echo "-------------------------------------------------"
git status
echo "================================================="

# -------- Check for Changes --------
if git diff --quiet && git diff --cached --quiet; then
    echo "[INFO] No changes detected. Nothing to commit."
    exit 0
fi

# -------- User Confirmation --------
read -r -p "Confirm adding and committing all changes? (y/n): " confirm
case "$confirm" in
    y|Y) ;;
    *)
        echo -e "${YELLOW}[INFO] Operation cancelled.${NC}"
        exit 0
        ;;
esac

# -------- Execute Git Operations --------
echo "[STEP] git add --all"
git add --all

echo "[STEP] git commit"
git commit -m "$COMMIT_MSG"

echo "[STEP] git push"
git push

echo -e "${GREEN}Done successfully.${NC}"
