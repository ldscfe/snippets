tmux() {
local HELP='==============================================================================
Command Name:   tmux (Enhanced Wrapper)
Description:    Terminal Multiplexer workspace manager with auto-cheat-sheet.
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-06-03
Version:        1.0.0
Compatibility:  macOS (BSD), Linux (GNU)

Usage:
    tmux [command] [options]       Pass through directly to original tmux

Commands & Shortcuts:
    tmux ls                        List all active sessions
    tmux new -s <name>             Create a new named session
    tmux a -t <name>               Attach to an existing session
    tmux kill-session -t <name>    Kill a specific session
    tmux kill-server               Kill all sessions and server
    
    Ctrl + b, d                    Detach from current session
    Ctrl + b, %                    Split pane vertically
    Ctrl + b, "                    Split pane horizontally

------------------------------------------------------------------------------'

    if [ $# -eq 0 ]; then
        echo -e "${CYAN}${HELP}${NC}\n"
        
        if command tmux ls >/dev/null 2>&1; then
            echo -e "${YELLOW}Current Active Sessions:${NC}"
            command tmux ls
            echo ""
            echo -e "${CYAN}==============================================================================${NC}"
        else
            echo -e "${YELLOW}No active tmux sessions right now.${NC}"
        fi
    else
        command tmux "$@"
    fi
}
