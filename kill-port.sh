#!/bin/bash

# Version information
SCRIPT_NAME="Kill Port"
VERSION="1.0.0"
AUTHOR="DARKHORSEONE LIMITED"
LICENSE="MIT License"
DESCRIPTION="Interactive command-line tool to find and kill processes running on specific ports"

# Parse command line arguments
AUTO_REFRESH=false
REFRESH_INTERVAL=5

# Function to show version information
show_version() {
    echo "$SCRIPT_NAME v$VERSION"
    echo "$DESCRIPTION"
    echo ""
    echo "Author: $AUTHOR"
    echo "License: $LICENSE"
    echo ""
    echo "Features:"
    echo "  • Interactive port browsing with fzf"
    echo "  • Process preview and confirmation dialogs"
    echo "  • Optional auto-refresh functionality"
    echo "  • Cross-platform compatibility (macOS/Linux)"
    echo ""
    echo "Repository: https://github.com/darkhorseone/kill-port"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --auto-refresh, -a    Enable auto-refresh every 5 seconds (default: disabled)"
    echo "  --interval N, -i N    Set auto-refresh interval in seconds (default: 5)"
    echo "  --version, -v        Show version information"
    echo "  --help, -h           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                   # Run without auto-refresh"
    echo "  $0 --auto-refresh    # Run with auto-refresh every 5 seconds"
    echo "  $0 -a -i 10          # Run with auto-refresh every 10 seconds"
    echo "  $0 --version         # Show version information"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-refresh|-a)
            AUTO_REFRESH=true
            shift
            ;;
        --interval|-i)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                REFRESH_INTERVAL="$2"
                shift 2
            else
                echo "Error: --interval requires a positive number" >&2
                exit 1
            fi
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            show_usage
            exit 1
            ;;
    esac
done

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed." >&2
    echo "This script requires fzf, a command-line fuzzy finder." >&2
    echo "" >&2
    echo "To install fzf:" >&2
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "On macOS (using Homebrew): brew install fzf" >&2
    elif [[ "$(uname)" == "Linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo "On Debian/Ubuntu: sudo apt-get update && sudo apt-get install fzf" >&2
        elif command -v yum &> /dev/null; then
            echo "On RHEL/CentOS/Amazon Linux: sudo yum install fzf" >&2
        elif command -v dnf &> /dev/null; then
            echo "On Fedora/Amazon Linux 2: sudo dnf install fzf" >&2
        else
            echo "Could not detect package manager. Please install fzf manually from https://github.com/junegunn/fzf" >&2
        fi
    fi
    exit 1
fi

# Global variables to track preview state
CURRENT_SELECTED_LINE=""
CURRENT_PREVIEW_MODE="preview"

# Function to handle port actions (preview or kill).
# It's defined to be called by fzf's preview and bind actions.
handle_port_action() {
    local line="$1"
    local action="$2" # 'preview', 'confirm', or 'kill'

    # For macOS `netstat -anv` output, the 4th column is the local address.
    # It can be in formats like: *.80, 127.0.0.1.5000, or localhost.631
    # We extract the 4th column and then use sed to get only the port number
    # by removing everything up to the last dot.
    local port_str=$(echo "$line" | awk '{print $4}')
    local port=$(echo "$port_str" | sed 's/.*\.//')

    # Check if port is a valid number
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "Could not determine a valid port from '$port_str'."
        return
    fi

    # Find PIDs for the given port. Redirect stderr to hide "not found" messages.
    local pids=$(lsof -t -i :"$port" 2>/dev/null)

    if [[ -z "$pids" ]]; then
        echo "No process found running on port $port."
        return
    fi

    if [[ "$action" == "preview" ]]; then
        # Update current state
        CURRENT_SELECTED_LINE="$line"
        CURRENT_PREVIEW_MODE="preview"
        # Show process details for the preview
        lsof -i :"$port"
    elif [[ "$action" == "confirm" ]]; then
        # Update current state
        CURRENT_SELECTED_LINE="$line"
        CURRENT_PREVIEW_MODE="confirm"
        # Show confirmation message
        echo "═══════════════════════════════════════════════════════════════"
        echo "CONFIRM KILL PROCESS ON PORT $port"
        echo "═══════════════════════════════════════════════════════════════"
        lsof -i :"$port"
        echo ""
        echo "┌─ AVAILABLE ACTIONS ─────────────────────────────────────────┐"
        echo "│ Y: Kill the process and return to main interface            │"
        echo "│ N: Cancel and return to main interface                      │"
        echo "│ Q: Quit the program                                         │"
        echo "│ Enter: Do nothing (stay in confirmation mode)               │"
        echo "└─────────────────────────────────────────────────────────────┘"
    elif [[ "$action" == "preserve" ]]; then
        # Preserve current preview state during auto-refresh
        if [[ "$CURRENT_PREVIEW_MODE" == "confirm" ]]; then
            handle_port_action "$CURRENT_SELECTED_LINE" "confirm"
        else
            handle_port_action "$CURRENT_SELECTED_LINE" "preview"
        fi
    elif [[ "$action" == "kill" ]]; then
        # Kill the process(es)
        echo "$pids" | while read -r pid; do
            if kill -9 "$pid"; then
                echo "Successfully killed process with PID $pid on port $port."
            else
                echo "Failed to kill process with PID $pid on port $port."
            fi
        done
        echo ""
        echo "Port list will reload automatically..."
        sleep 1 # Brief pause to allow user to read the message
    fi
}

# Function to get listening ports
get_listening_ports() {
    netstat -anv | grep LISTEN
}

# Function to check if selected port still exists
port_still_exists() {
    local line="$1"
    if [[ -z "$line" ]]; then
        return 1
    fi
    
    local port_str=$(echo "$line" | awk '{print $4}')
    local port=$(echo "$port_str" | sed 's/.*\.//')
    
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Check if port still has listening processes
    lsof -t -i :"$port" >/dev/null 2>&1
}

# Function to run the fzf interface with or without timeout
run_fzf_interface() {
    # Determine preview command based on whether we need to preserve state
    local preview_cmd='handle_port_action {} preview'
    if [[ -n "$CURRENT_SELECTED_LINE" ]] && port_still_exists "$CURRENT_SELECTED_LINE"; then
        # If the selected port still exists, try to preserve the preview state
        if [[ "$CURRENT_PREVIEW_MODE" == "confirm" ]]; then
            preview_cmd='if [[ "{}" == "'"$CURRENT_SELECTED_LINE"'" ]]; then handle_port_action {} preserve; else handle_port_action {} preview; fi'
        fi
    else
        # Reset state if port no longer exists
        CURRENT_SELECTED_LINE=""
        CURRENT_PREVIEW_MODE="preview"
    fi
    
    # Build header message
    local header_msg="Use arrow keys to navigate, press 'K' to kill (with confirmation), 'Q' to quit"
    if [[ "$AUTO_REFRESH" == "true" ]]; then
        header_msg="$header_msg | Auto-refresh: ${REFRESH_INTERVAL}s"
    fi
    header_msg="$header_msg | R: Manual refresh"
    
    if [[ "$AUTO_REFRESH" == "true" ]]; then
        # Run with auto-refresh timeout
        get_listening_ports | SHELL=/bin/bash fzf \
            --header "$header_msg" \
            --bind "k:change-preview(handle_port_action {} confirm)" \
            --bind "y:execute(handle_port_action {} kill)+reload(get_listening_ports)+change-preview(handle_port_action {} preview)" \
            --bind "n:change-preview(handle_port_action {} preview)" \
            --bind "q:abort" \
            --bind "enter:ignore" \
            --bind "r:reload(get_listening_ports)" \
            --preview "$preview_cmd" \
            --preview-window=up:45%:wrap \
            --height=100% &
        
        local fzf_pid=$!
        
        # Wait for either fzf to exit or timeout
        local count=0
        while [[ $count -lt $REFRESH_INTERVAL ]]; do
            if ! kill -0 $fzf_pid 2>/dev/null; then
                # fzf has exited
                wait $fzf_pid
                return $?
            fi
            sleep 1
            ((count++))
        done
        
        # Timeout reached, kill fzf to trigger refresh
        kill $fzf_pid 2>/dev/null || true
        wait $fzf_pid 2>/dev/null || true
        return 0  # Return 0 to indicate timeout (continue loop)
    else
        # Run without auto-refresh - standard fzf behavior
        get_listening_ports | SHELL=/bin/bash fzf \
            --header "$header_msg" \
            --bind "k:change-preview(handle_port_action {} confirm)" \
            --bind "y:execute(handle_port_action {} kill)+reload(get_listening_ports)+change-preview(handle_port_action {} preview)" \
            --bind "n:change-preview(handle_port_action {} preview)" \
            --bind "q:abort" \
            --bind "enter:ignore" \
            --bind "r:reload(get_listening_ports)" \
            --preview "$preview_cmd" \
            --preview-window=up:45%:wrap \
            --height=100%
        
        return $?
    fi
}

# Export the functions so subshells started by fzf (with bash) can find them.
export -f handle_port_action
export -f get_listening_ports
export -f port_still_exists
export -f run_fzf_interface

# Export global variables
export CURRENT_SELECTED_LINE
export CURRENT_PREVIEW_MODE

# Main execution
if [[ "$AUTO_REFRESH" == "true" ]]; then
    # Auto-refresh mode - run in loop
    while true; do
        # Save terminal state
        tput smcup 2>/dev/null || true
        
        # Run fzf interface
        result=$(run_fzf_interface)
        exit_code=$?
        
        # Restore terminal state
        tput rmcup 2>/dev/null || true
        
        # Check exit conditions
        if [[ $exit_code -eq 0 ]]; then
            # User made a selection or timeout occurred - continue loop for auto-refresh
            continue
        elif [[ $exit_code -eq 1 ]]; then
            # User pressed q - exit normally
            echo "Goodbye!"
            break
        elif [[ $exit_code -eq 130 ]]; then
            # User pressed Ctrl+C - exit
            echo "Bye. ($SCRIPT_NAME v$VERSION, powered by $AUTHOR)"
            break
        elif [[ $exit_code -eq 143 ]] || [[ $exit_code -eq 15 ]]; then
            # SIGTERM from auto-refresh timeout - continue loop
            continue
        else
            # Other exit codes - continue for auto-refresh
            continue
        fi
    done
else
    # Single run mode - no auto-refresh
    run_fzf_interface
    exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        echo "Goodbye!"
    elif [[ $exit_code -eq 130 ]]; then
        echo "Bye. ($SCRIPT_NAME v$VERSION, powered by $AUTHOR)"
    fi
fi