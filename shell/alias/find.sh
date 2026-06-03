find() {
local HELP='==============================================================================
Command Name:   find (Enhanced Wrapper)
Description:    Search for files in a directory hierarchy.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-06-03
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    find [command] [options]       Pass through directly to original find

Commands & Shortcuts:
    find . -name "*.log"           Find files by name (wildcard)
    find . -type f                 Find files only (f: file, d: directory)
    find . -size +100M             Find files larger than 100MB
    find . -name "*.tmp" -delete   Find and delete matched files
    find . -name "*.sh" -exec chmod +x {} +  Find and execute command on files

------------------------------------------------------------------------------'

    if [ $# -eq 0 ]; then
        echo -e "${CYAN}${HELP}${NC}\n"
        
        echo -e "${YELLOW}Top 15 files in current directory:${NC}"
        command find . -maxdepth 1 -type f | head -15
    else
        command find "$@"
    fi
}
