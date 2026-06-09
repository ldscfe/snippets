git() {
local HELP='==============================================================================
Command Name:   git (Enhanced Wrapper)
Description:    Distributed version control system with auto-cheat-sheet.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-06-03
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    git [command] [options]        Pass through directly to original git

Commands & Shortcuts:
    git status                     Show the working tree status
    git log --oneline -10          Show recent 10 commits in one line
    git branch -a                  List both remote-tracking and local branches
    git add -A                     Add all tracking and untracked modified files
    git commit -m "msg"            Record changes to the repository
    git push                       Update remote refs along with associated objects
    git pull                       Fetch from and integrate with another repository

------------------------------------------------------------------------------'

    if [ $# -eq 0 ]; then
        # 这里使用 GREEN 绿色作为 Git 的主色调，如果没有定义则会留空不改变颜色
        echo -e "${GREEN}${HELP}${NC}\n"
        
        if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo -e "${YELLOW}Current Repository Status:${NC}"
            command git status --short
            echo ""
            echo -e "${GREEN}==============================================================================${NC}"
        else
            echo -e "${YELLOW}Not a git repository (or any of the parent directories)${NC}"
        fi
    else
        command git "$@"
    fi
}


push() (
local HELP='==============================================================================
Script Name:    push.sh
Description:    Automated Git status, commit, and push script.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-05-09
Version:        1.2.0
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

# --- Help ---
if [[ "$#" -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    return 0
fi

set -euo pipefail

PROJECT_DIR="${1:-}"
COMMIT_MSG="${2:-"chore: auto update by script $(date +'%Y-%m-%d %H:%M:%S')"}"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo -e "${RED}[ERROR] Directory does not exist: $PROJECT_DIR${NC}"
    return 1
fi

cd "$PROJECT_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Not a Git repository: $PROJECT_DIR${NC}"
    return 1
fi

# -------- Git Status --------
echo "================================================="
echo "📦 Project: $(pwd)"
echo "-------------------------------------------------"
git status
echo "================================================="

# -------- Check for Changes --------
if [[ -z "$(git status --porcelain)" ]]; then
    echo "[INFO] No changes detected. Nothing to commit."
    return 0
fi

# -------- User Confirmation --------
read -r -p "Confirm adding and committing all changes? (y/n): " confirm
case "$confirm" in
    y|Y) ;;
    *)
        echo -e "${YELLOW}[INFO] Operation cancelled.${NC}"
        return 0
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

)


ugit() (
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
        echo -e "${BLUE}Checking:${CYAN} $dir${NC}"
        (
            cd "$FULL_PATH" || exit 1

            # Git status
            ST_OUTPUT=$(git status --porcelain)

            if [[ -n "$ST_OUTPUT" ]]; then
                echo -e "${YELLOW}$ST_OUTPUT${NC}"
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

)
