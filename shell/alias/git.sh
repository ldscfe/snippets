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