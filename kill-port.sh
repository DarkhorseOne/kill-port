#!/bin/bash

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

# Function to handle port actions (preview or kill).
# It's defined to be called by fzf's preview and bind actions.
handle_port_action() {
    local line="$1"
    local action="$2" # 'preview' or 'kill'

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
        # Show process details for the preview
        lsof -i :"$port"
    elif [[ "$action" == "kill" ]]; then
        # Kill the process(es)
        echo "$pids" | while read -r pid; do
            if kill -9 "$pid"; then
                echo "Successfully killed process with PID $pid on port $port."
            else
                echo "Failed to kill process with PID $pid on port $port."
            fi
        done
        sleep 2 # Pause to allow user to read the message
    fi
}

# Export the function so subshells started by fzf (with bash) can find it.
export -f handle_port_action

# Get the list of listening ports and pipe it to fzf.
# We prepend `SHELL=/bin/bash` to the fzf command to ensure that it uses
# bash for its sub-commands (`--preview` and `execute(...)`).
# This is crucial for two reasons:
# 1. It makes the exported `handle_port_action` bash function available.
# 2. It avoids shell-specific behaviors and errors, like zsh's 'no matches found'
#    globbing error.
netstat -anv | grep LISTEN | SHELL=/bin/bash fzf \
    --header "Use arrow keys to navigate, press 'K' to kill the selected process" \
    --bind "k:execute(handle_port_action {} kill)+abort" \
    --preview 'handle_port_action {} preview' \
    --preview-window=up:5:wrap