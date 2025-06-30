#!/bin/bash

# Version information
SCRIPT_NAME="Kill Port"
VERSION="1.0.1"
AUTHOR="DARKHORSEONE LIMITED"
LICENSE="MIT License"
DESCRIPTION="Interactive command-line tool to find and kill processes running on specific ports"

# Parse command line arguments
AUTO_REFRESH=false
REFRESH_INTERVAL=5
USE_COLOR=false

# Color definitions
if [[ -t 1 ]]; then
    # Terminal supports colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[0;37m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    
    # Bright colors
    BRIGHT_RED='\033[1;31m'
    BRIGHT_GREEN='\033[1;32m'
    BRIGHT_YELLOW='\033[1;33m'
    BRIGHT_BLUE='\033[1;34m'
    BRIGHT_MAGENTA='\033[1;35m'
    BRIGHT_CYAN='\033[1;36m'
    BRIGHT_WHITE='\033[1;37m'
else
    # No color support
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
    BOLD=''
    DIM=''
    RESET=''
    BRIGHT_RED=''
    BRIGHT_GREEN=''
    BRIGHT_YELLOW=''
    BRIGHT_BLUE=''
    BRIGHT_MAGENTA=''
    BRIGHT_CYAN=''
    BRIGHT_WHITE=''
fi

# Function to colorize text based on USE_COLOR setting
colorize() {
    local color_code="$1"
    local text="$2"
    
    if [[ "$USE_COLOR" == "true" ]]; then
        echo -e "${color_code}${text}${RESET}"
    else
        echo "$text"
    fi
}

# Function to show version information
show_version() {
    colorize "$BOLD$BRIGHT_CYAN" "$SCRIPT_NAME v$VERSION"
    colorize "$DIM" "$DESCRIPTION"
    echo ""
    colorize "$YELLOW" "Author: $AUTHOR"
    colorize "$YELLOW" "License: $LICENSE"
    echo ""
    colorize "$BOLD$GREEN" "Features:"
    colorize "$GREEN" "  • Interactive port browsing with fzf"
    colorize "$GREEN" "  • Process preview and confirmation dialogs"
    colorize "$GREEN" "  • Optional auto-refresh functionality"
    colorize "$GREEN" "  • Cross-platform compatibility (macOS/Linux)"
    colorize "$GREEN" "  • Beautiful colored output (optional)"
    echo ""
    colorize "$BLUE" "Repository: https://github.com/darkhorseone/kill-port"
}

# Function to show usage
show_usage() {
    colorize "$BOLD$BRIGHT_WHITE" "Usage: $0 [OPTIONS]"
    echo ""
    colorize "$BOLD$YELLOW" "Options:"
    colorize "$CYAN" "  --auto-refresh, -a    Enable auto-refresh every 5 seconds (default: disabled)"
    colorize "$CYAN" "  --interval N, -i N    Set auto-refresh interval in seconds (default: 5)"
    colorize "$CYAN" "  --color, -c           Enable beautiful colored output (default: disabled)"
    colorize "$CYAN" "  --no-color            Disable colored output (override --color)"
    colorize "$CYAN" "  --version, -v         Show version information"
    colorize "$CYAN" "  --help, -h            Show this help message"
    echo ""
    colorize "$BOLD$GREEN" "Examples:"
    colorize "$GREEN" "  $0                    # Run without auto-refresh or colors"
    colorize "$GREEN" "  $0 --color            # Run with beautiful colored output"
    colorize "$GREEN" "  $0 --auto-refresh     # Run with auto-refresh every 5 seconds"
    colorize "$GREEN" "  $0 -a -i 10 -c        # Run with auto-refresh every 10 seconds and colors"
    colorize "$GREEN" "  $0 --version          # Show version information"
}

# Parse arguments
SHOW_VERSION=false
SHOW_HELP=false

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
        --color|-c)
            USE_COLOR=true
            shift
            ;;
        --no-color)
            USE_COLOR=false
            shift
            ;;
        --version|-v)
            SHOW_VERSION=true
            shift
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            SHOW_HELP=true
            break
            ;;
    esac
done

# Handle version and help after all arguments are parsed
if [[ "$SHOW_VERSION" == "true" ]]; then
    show_version
    exit 0
fi

if [[ "$SHOW_HELP" == "true" ]]; then
    show_usage
    exit 0
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    if [[ "$USE_COLOR" == "true" ]]; then
        echo -e "${BRIGHT_RED}Error: fzf is not installed.${RESET}" >&2
        echo -e "${YELLOW}This script requires fzf, a command-line fuzzy finder.${RESET}" >&2
        echo "" >&2
        echo -e "${BOLD}${CYAN}To install fzf:${RESET}" >&2
        if [[ "$(uname)" == "Darwin" ]]; then
            echo -e "${GREEN}On macOS (using Homebrew): brew install fzf${RESET}" >&2
        elif [[ "$(uname)" == "Linux" ]]; then
            if command -v apt-get &> /dev/null; then
                echo -e "${GREEN}On Debian/Ubuntu: sudo apt-get update && sudo apt-get install fzf${RESET}" >&2
            elif command -v yum &> /dev/null; then
                echo -e "${GREEN}On RHEL/CentOS/Amazon Linux: sudo yum install fzf${RESET}" >&2
            elif command -v dnf &> /dev/null; then
                echo -e "${GREEN}On Fedora/Amazon Linux 2: sudo dnf install fzf${RESET}" >&2
            else
                echo -e "${GREEN}Could not detect package manager. Please install fzf manually from https://github.com/junegunn/fzf${RESET}" >&2
            fi
        fi
    else
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
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${YELLOW}Could not determine a valid port from '$port_str'.${RESET}"
        else
            echo "Could not determine a valid port from '$port_str'."
        fi
        return
    fi

    # Find PIDs for the given port. Redirect stderr to hide "not found" messages.
    local pids=$(lsof -t -i :"$port" 2>/dev/null)

    if [[ -z "$pids" ]]; then
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${DIM}No process found running on port $port.${RESET}"
        else
            echo "No process found running on port $port."
        fi
        return
    fi

    if [[ "$action" == "preview" ]]; then
        # Update current state
        CURRENT_SELECTED_LINE="$line"
        CURRENT_PREVIEW_MODE="preview"
        # Show process details for the preview
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${BOLD}${BRIGHT_CYAN}🔍 Process Details for Port $port${RESET}"
            echo ""
            # Use colored lsof output
            lsof -i :"$port" | while IFS= read -r line; do
                if [[ "$line" =~ ^COMMAND ]]; then
                    # Header line
                    echo -e "${BOLD}${YELLOW}$line${RESET}"
                else
                    # Process line - colorize different parts manually
                    # Extract components
                    command=$(echo "$line" | awk '{print $1}')
                    pid=$(echo "$line" | awk '{print $2}')
                    user=$(echo "$line" | awk '{print $3}')
                    fd=$(echo "$line" | awk '{print $4}')
                    type=$(echo "$line" | awk '{print $5}')
                    device=$(echo "$line" | awk '{print $6}')
                    size=$(echo "$line" | awk '{print $7}')
                    node=$(echo "$line" | awk '{print $8}')
                    name=$(echo "$line" | awk '{print $9}')
                    
                    # Print with colors
                    printf "${BRIGHT_GREEN}%-12s${RESET} ${BRIGHT_BLUE}%-8s${RESET} ${CYAN}%-10s${RESET} ${YELLOW}%-6s${RESET} ${MAGENTA}%-6s${RESET} ${WHITE}%-8s${RESET} ${DIM}%-8s${RESET} ${DIM}%-8s${RESET} ${GREEN}%s${RESET}\n" \
                           "$command" "$pid" "$user" "$fd" "$type" "$device" "$size" "$node" "$name"
                fi
            done
        else
            lsof -i :"$port"
        fi
    elif [[ "$action" == "confirm" ]]; then
        # Update current state
        CURRENT_SELECTED_LINE="$line"
        CURRENT_PREVIEW_MODE="confirm"
        # Show confirmation message
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${BOLD}${RED}═══════════════════════════════════════════════════════════════${RESET}"
            echo -e "${BOLD}${BRIGHT_RED}⚠️  CONFIRM KILL PROCESS ON PORT $port${RESET}"
            echo -e "${BOLD}${RED}═══════════════════════════════════════════════════════════════${RESET}"
            # Show process details with colors
            lsof -i :"$port" | while IFS= read -r line; do
                if [[ "$line" =~ ^COMMAND ]]; then
                    echo -e "${BOLD}${YELLOW}$line${RESET}"
                else
                    # Process line - colorize different parts manually
                    # Extract components
                    command=$(echo "$line" | awk '{print $1}')
                    pid=$(echo "$line" | awk '{print $2}')
                    user=$(echo "$line" | awk '{print $3}')
                    fd=$(echo "$line" | awk '{print $4}')
                    type=$(echo "$line" | awk '{print $5}')
                    device=$(echo "$line" | awk '{print $6}')
                    size=$(echo "$line" | awk '{print $7}')
                    node=$(echo "$line" | awk '{print $8}')
                    name=$(echo "$line" | awk '{print $9}')
                    
                    # Print with colors
                    printf "${BRIGHT_GREEN}%-12s${RESET} ${BRIGHT_BLUE}%-8s${RESET} ${CYAN}%-10s${RESET} ${YELLOW}%-6s${RESET} ${MAGENTA}%-6s${RESET} ${WHITE}%-8s${RESET} ${DIM}%-8s${RESET} ${DIM}%-8s${RESET} ${GREEN}%s${RESET}\n" \
                           "$command" "$pid" "$user" "$fd" "$type" "$device" "$size" "$node" "$name"
                fi
            done
            echo ""
            echo -e "${BOLD}${CYAN}┌─ AVAILABLE ACTIONS ─────────────────────────────────────────┐${RESET}"
            echo -e "${CYAN}│ Y: Kill the process and return to main interface            │${RESET}"
            echo -e "${CYAN}│ N: Cancel and return to main interface                      │${RESET}"
            echo -e "${CYAN}│ Q: Quit the program                                         │${RESET}"
            echo -e "${CYAN}│ Enter: Do nothing (stay in confirmation mode)               │${RESET}"
            echo -e "${BOLD}${CYAN}└─────────────────────────────────────────────────────────────┘${RESET}"
        else
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
        fi
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
                if [[ "$USE_COLOR" == "true" ]]; then
                    echo -e "${BRIGHT_GREEN}✓ Successfully killed process with PID $pid on port $port.${RESET}"
                else
                    echo "✓ Successfully killed process with PID $pid on port $port."
                fi
            else
                if [[ "$USE_COLOR" == "true" ]]; then
                    echo -e "${BRIGHT_RED}✗ Failed to kill process with PID $pid on port $port.${RESET}"
                else
                    echo "✗ Failed to kill process with PID $pid on port $port."
                fi
            fi
        done
        echo ""
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${BLUE}🔄 Port list will reload automatically...${RESET}"
        else
            echo "🔄 Port list will reload automatically..."
        fi
        sleep 1 # Brief pause to allow user to read the message
    fi
}

# Function to get listening ports
get_listening_ports() {
    # Add table header
    if [[ "$USE_COLOR" == "true" ]]; then
        echo -e "${BOLD}${CYAN}PROTO      RECV-Q SEND-Q LOCAL ADDRESS          FOREIGN ADDRESS        STATE${RESET}"
        echo -e "${DIM}────────── ────── ────── ────────────────────── ────────────────────── ──────${RESET}"
        # Apply colors to the port list while preserving original format
        netstat -anv | grep LISTEN | while IFS= read -r line; do
            # Apply colors using echo -e for proper escape sequence handling
            echo -e "$line" | \
                sed -e "s/^tcp[46]/$(printf '\033[0;35m')&$(printf '\033[0m')/" \
                    -e "s/^udp[46]/$(printf '\033[0;35m')&$(printf '\033[0m')/" \
                    -e "s/\*\.[0-9][0-9]*/$(printf '\033[1;32m')&$(printf '\033[0m')/g" \
                    -e "s/[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/$(printf '\033[1;32m')&$(printf '\033[0m')/g" \
                    -e "s/LISTEN/$(printf '\033[1;33m')&$(printf '\033[0m')/g"
        done
    else
        # No colors, just return normal output with header
        echo "PROTO      RECV-Q SEND-Q LOCAL ADDRESS          FOREIGN ADDRESS        STATE"
        echo "────────── ────── ────── ────────────────────── ────────────────────── ──────"
        netstat -anv | grep LISTEN
    fi
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
    
    # Build header message (keep simple for fzf header compatibility)
    local header_msg="Use arrow keys to navigate, press 'K' to kill (with confirmation), 'Q' to quit"
    if [[ "$AUTO_REFRESH" == "true" ]]; then
        header_msg="$header_msg | Auto-refresh: ${REFRESH_INTERVAL}s"
    fi
    header_msg="$header_msg | R: Manual refresh"
    
    if [[ "$AUTO_REFRESH" == "true" ]]; then
        # Run with auto-refresh timeout
        if [[ "$USE_COLOR" == "true" ]]; then
            get_listening_ports | USE_COLOR=true SHELL=/bin/bash fzf \
                --ansi \
                --header-lines=2 \
                --header "$header_msg" \
                --bind "k:change-preview(handle_port_action {} confirm)" \
                --bind "y:execute(handle_port_action {} kill)+reload(USE_COLOR=true get_listening_ports)+change-preview(handle_port_action {} preview)" \
                --bind "n:change-preview(handle_port_action {} preview)" \
                --bind "q:abort" \
                --bind "enter:ignore" \
                --bind "r:reload(USE_COLOR=true get_listening_ports)" \
                --preview "$preview_cmd" \
                --preview-window=up:20:wrap \
                --height=100% &
        else
            get_listening_ports | SHELL=/bin/bash fzf \
                --header-lines=2 \
                --header "$header_msg" \
                --bind "k:change-preview(handle_port_action {} confirm)" \
                --bind "y:execute(handle_port_action {} kill)+reload(get_listening_ports)+change-preview(handle_port_action {} preview)" \
                --bind "n:change-preview(handle_port_action {} preview)" \
                --bind "q:abort" \
                --bind "enter:ignore" \
                --bind "r:reload(get_listening_ports)" \
                --preview "$preview_cmd" \
                --preview-window=up:20:wrap \
                --height=100% &
        fi
        
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
        if [[ "$USE_COLOR" == "true" ]]; then
            get_listening_ports | USE_COLOR=true SHELL=/bin/bash fzf \
                --ansi \
                --header-lines=2 \
                --header "$header_msg" \
                --bind "k:change-preview(handle_port_action {} confirm)" \
                --bind "y:execute(handle_port_action {} kill)+reload(USE_COLOR=true get_listening_ports)+change-preview(handle_port_action {} preview)" \
                --bind "n:change-preview(handle_port_action {} preview)" \
                --bind "q:abort" \
                --bind "enter:ignore" \
                --bind "r:reload(USE_COLOR=true get_listening_ports)" \
                --preview "$preview_cmd" \
                --preview-window=up:20:wrap \
                --height=100%
        else
            get_listening_ports | SHELL=/bin/bash fzf \
                --header-lines=2 \
                --header "$header_msg" \
                --bind "k:change-preview(handle_port_action {} confirm)" \
                --bind "y:execute(handle_port_action {} kill)+reload(get_listening_ports)+change-preview(handle_port_action {} preview)" \
                --bind "n:change-preview(handle_port_action {} preview)" \
                --bind "q:abort" \
                --bind "enter:ignore" \
                --bind "r:reload(get_listening_ports)" \
                --preview "$preview_cmd" \
                --preview-window=up:20:wrap \
                --height=100%
        fi
        
        return $?
    fi
}

# Export the functions so subshells started by fzf (with bash) can find them.
export -f handle_port_action
export -f get_listening_ports
export -f port_still_exists
export -f run_fzf_interface
export -f colorize

# Export global variables
export CURRENT_SELECTED_LINE
export CURRENT_PREVIEW_MODE
export USE_COLOR

# Export color variables for subshells
export RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BOLD DIM RESET
export BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN BRIGHT_WHITE

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
            if [[ "$USE_COLOR" == "true" ]]; then
                echo -e "${BRIGHT_GREEN}👋 Goodbye!${RESET}"
            else
                echo "👋 Goodbye!"
            fi
            break
        elif [[ $exit_code -eq 130 ]]; then
            # User pressed Ctrl+C - exit
            if [[ "$USE_COLOR" == "true" ]]; then
                echo -e "${BRIGHT_CYAN}👋 Bye. ($SCRIPT_NAME v$VERSION, Made by $AUTHOR)${RESET}"
            else
                echo "👋 Bye. ($SCRIPT_NAME v$VERSION, Made by $AUTHOR)"
            fi
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
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${BRIGHT_GREEN}👋 Goodbye!${RESET}"
        else
            echo "👋 Goodbye!"
        fi
    elif [[ $exit_code -eq 130 ]]; then
        if [[ "$USE_COLOR" == "true" ]]; then
            echo -e "${BRIGHT_CYAN}👋 Bye. ($SCRIPT_NAME v$VERSION, Made by $AUTHOR)${RESET}"
        else
            echo "👋 Bye. ($SCRIPT_NAME v$VERSION, Made by $AUTHOR)"
        fi
    fi
fi