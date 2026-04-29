#!/bin/bash
# =================================================================
# Description: Automated Git status / commit / push script
# Author: Adam Lee
# Date: 2026-02-11
# =================================================================

# Color definitions
COMMON_LIB="$HOME/bin/common.sh"
if [ -f "$COMMON_LIB" ]; then
    source "$COMMON_LIB"
fi

set -euo pipefail

# -------- HELP --------
show_help() {
    echo -e "${GREEN}Git Auto-Push Script Help${NC}"
    echo "-------------------------------------------------"
    echo "Usage: $0 <project_dir> [commit_message]"
    echo ""
    echo "Arguments:"
    echo "  project_dir      Local path of Git project (required)"
    echo "  commit_message   Custom commit message (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 .                                 # Commit current directory with default message"
    echo "  $0 ~/my-repo \"feat: add login\"       # Commit specified directory with custom message"
    echo "  $0 -h / --help                       # Show this help information"
    echo "-------------------------------------------------"
}

# -------- Argument Processing --------
# Check if arguments are provided or help is requested
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

PROJECT_DIR="${1:-}"
CUSTOM_MSG="${2:-}"

if [[ -z "$PROJECT_DIR" ]]; then
    echo -e "${YELLOW}Usage: $0 <project_dir> [commit_message]${NC}"
    exit 1
fi

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

# -------- Commit Message --------
DT="$(date '+%Y/%m/%d %H:%M:%S')"
if [[ -n "$CUSTOM_MSG" ]]; then
    COMMIT_MSG="$CUSTOM_MSG, $DT"
else
    COMMIT_MSG="chore: update files, $DT"
fi

# -------- Execute Git Operations --------
echo "[STEP] git add ."
git add .

echo "[STEP] git commit"
git commit -m "$COMMIT_MSG"

echo "[STEP] git push"
git push

echo -e "${GREEN}Done successfully.${NC}"
