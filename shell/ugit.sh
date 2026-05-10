#!/bin/bash

HELP='==============================================================================
Script Name:    ugit
Description:    Batch git operations (status/pull) for current user.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-10
Version:        1.5.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    ugit [status|pull]
    ugit -h | --help

Options:
    status      Show git status for repositories (default)
    pull        Pull updates for repositories

Examples:
    ugit                # status
    ugit pull           # pull
=============================================================================='

# --- Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

set -u

# --- Path & Repository Detection ---
BASE_DIR="$PWD"
REPOS=()

# If current directory itself is a git repo
if [[ -d "$BASE_DIR/.git" ]]; then
    REPOS+=("$BASE_DIR")
else
    # Otherwise scan first-level subdirectories
    for dir in "$BASE_DIR"/*; do
        [[ -d "$dir/.git" ]] && REPOS+=("$dir")
    done
fi

# --- No Repository Found ---
if [[ ${#REPOS[@]} -eq 0 ]]; then
    echo -e "${YELLOW}[INFO] No git repositories found.${NC}"
    exit 0
fi

# --- Action ---
ACTION="status"
[[ "${1:-}" == "pull" ]] && ACTION="pull"

echo -e "${BLUE}Action:${NC} ${GREEN}$ACTION${NC} | ${BLUE}User:${NC} ${CYAN}$(whoami)${NC}"

# --- Execution ---
for FULL_PATH in "${REPOS[@]}"; do
    dir=$(basename "$FULL_PATH")

    echo -e "${NC}------------------------------------------------"

    if [[ "$ACTION" == "status" ]]; then
        echo -e "${CYAN}Checking:${NC} $dir"
        (
            cd "$FULL_PATH" || exit 1

            # Git status
            ST_OUTPUT=$(git status --porcelain)

            if [[ -n "$ST_OUTPUT" ]]; then
                echo "$ST_OUTPUT"
            fi

            # Unpushed commits
            UNPUSHED=0

            if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
                UNPUSHED=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
            fi

            if [[ "$UNPUSHED" -gt 0 ]]; then
                echo -e "    ${YELLOW}↑ $UNPUSHED commits to push${NC}"

                # Ask whether to push
                echo -ne "    ${CYAN}Do you want to push now? (y/n): ${NC}"
                read -r CONFIRM

                if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                    echo -e "    ${BLUE}Pushing to remote...${NC}"

                    if git push; then
                        echo -e "    ${GREEN}✔ Push successful!${NC}"
                    else
                        echo -e "    ${RED}✘ Push failed.${NC}"
                    fi
                else
                    echo -e "    ${BLUE}➡ Skipped push.${NC}"
                fi
            fi

            # Clean repo
            if [[ -z "$ST_OUTPUT" && "$UNPUSHED" -eq 0 ]]; then
                echo -e "    ${BLUE}➜ Clean${NC}"
            fi
        )
    else
        echo -e "${CYAN}Pulling:${NC} $dir"
        (
            cd "$FULL_PATH" || exit 1

            # Save current commit
            OLD_HEAD=$(git rev-parse HEAD 2>/dev/null)

            # Pull updates
            if git pull --quiet >/dev/null 2>&1; then
                NEW_HEAD=$(git rev-parse HEAD 2>/dev/null)
                if [[ "$OLD_HEAD" == "$NEW_HEAD" ]]; then
                    echo -e "    ${BLUE}➜ No changes.${NC}"
                else
                    DIFF_COUNT=$(git diff --name-only "$OLD_HEAD" "$NEW_HEAD" | wc -l | xargs)
                    echo -e "    ${GREEN}✔ Updated $DIFF_COUNT files.${NC}"
                fi
            else
                echo -e "    ${RED}✘ Pull failed.${NC}"
            fi
        )
    fi
done

echo -e "${NC}------------------------------------------------"
