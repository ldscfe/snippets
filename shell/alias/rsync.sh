rsync() {
local HELP='==============================================================================
Command Name:   rsync (Enhanced Wrapper)
Description:    Fast, versatile, remote and local file copying tool.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-06-03
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    rsync [command] [options]      Pass through directly to original rsync

Commands & Shortcuts:
    rsync -avz --progress src/ dst/  Archive mode with compression and progress

Common Options:
    -a                             Archive mode (equals -rlptgoD)
    -v                             Increase verbosity
    -z                             Compress file data during the transfer
    --delete                       Delete extraneous files from dest dirs
    --dry-run                      Perform a trial run with no changes

=============================================================================='

    if [ $# -eq 0 ]; then
        echo -e "${CYAN}${HELP}${NC}\n"
        echo "Usage example: ursync local/ user@remote:/path/"
    else
        command rsync "$@"
    fi
}
