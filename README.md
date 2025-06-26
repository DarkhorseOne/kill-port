# Kill Port

A powerful interactive command-line tool to find and kill processes running on specific ports using [fzf](https://github.com/junegunn/fzf) for a beautiful fuzzy-finding interface.

## Features

- 🔍 **Interactive port browsing** - View all listening ports with a fuzzy-finder interface
- 👀 **Process preview** - See detailed process information in a resizable preview window (45% height)
- ⚡ **Smart kill workflow** - Enhanced confirmation dialog with clear action prompts
- 🔄 **Optional auto-refresh** - Real-time port monitoring (disabled by default, configurable)
- 📋 **Immediate list reload** - Port list automatically updates after killing a process
- 🎛️ **Command line options** - Flexible configuration via command line parameters
- 🧠 **Smart preview persistence** - Maintains confirmation dialog during auto-refresh
- 🎯 **Multiple process handling** - Handles multiple processes on the same port
- 🛡️ **Safety checks** - Validates ports and handles errors gracefully
- 🖥️ **Cross-platform** - Works on macOS and Linux without external dependencies
- ⌨️ **Intuitive controls** - Clear action indicators and helpful key bindings
- 🎨 **Beautiful UI** - Professional-looking confirmation dialogs with borders

## Requirements

- **fzf** - Command-line fuzzy finder
- **bash** - The script requires bash to run
- **lsof** - For finding processes using specific ports (usually pre-installed)
- **netstat** - For listing network connections (usually pre-installed)

## Installation

### Installing fzf

The script will automatically detect your operating system and provide installation instructions if fzf is not found.

**macOS (using Homebrew):**
```bash
brew install fzf
```

**Ubuntu/Debian:**
```bash
sudo apt-get update && sudo apt-get install fzf
```

**RHEL/CentOS/Amazon Linux:**
```bash
sudo yum install fzf
```

**Fedora/Amazon Linux 2:**
```bash
sudo dnf install fzf
```

### Installing the script

1. Clone or download the `kill-port.sh` script
2. Make it executable:
   ```bash
   chmod +x kill-port.sh
   ```
3. (Optional) Add it to your PATH for global access:
   ```bash
   # Example: copy to /usr/local/bin
   sudo cp kill-port.sh /usr/local/bin/kill-port
   ```

## Usage

### Basic Usage

Run the script from your terminal:

```bash
# Basic usage (no auto-refresh)
./kill-port.sh

# With auto-refresh every 5 seconds
./kill-port.sh --auto-refresh

# With auto-refresh every 10 seconds
./kill-port.sh --auto-refresh --interval 10
```

### Command Line Options

```bash
Usage: ./kill-port.sh [OPTIONS]

Options:
  --auto-refresh, -a    Enable auto-refresh every 5 seconds (default: disabled)
  --interval N, -i N    Set auto-refresh interval in seconds (default: 5)
  --version, -v        Show version information
  --help, -h           Show this help message

Examples:
  ./kill-port.sh                   # Run without auto-refresh
  ./kill-port.sh --auto-refresh    # Run with auto-refresh every 5 seconds
  ./kill-port.sh -a -i 10          # Run with auto-refresh every 10 seconds
  ./kill-port.sh --version         # Show version information
```

Or if installed globally:

```bash
kill-port -a -i 3  # Auto-refresh every 3 seconds
kill-port --version  # Show version information
```

### Version Information

To see version details, features, and license information:

```bash
./kill-port.sh --version
```

Output example:
```
Kill Port v1.0.0
Interactive command-line tool to find and kill processes running on specific ports

Author: DARKHORSEONE LIMITED
License: MIT License

Features:
  • Interactive port browsing with fzf
  • Process preview and confirmation dialogs
  • Optional auto-refresh functionality
  • Cross-platform compatibility (macOS/Linux)

Repository: https://github.com/darkhorseone/kill-port
```

### Interface Controls

#### Main Interface
- **Arrow keys** - Navigate through the list of listening ports
- **K key** - Enter confirmation mode for killing the selected process
- **R** - Manually refresh the port list
- **Q/Esc/Ctrl+C** - Exit the application

#### Confirmation Mode
When you press 'K' to kill a process, you'll enter confirmation mode with these options:
- **Y** - Confirm kill, reload port list, and return to main interface
- **N** - Cancel and return to main interface  
- **Q** - Quit the program entirely
- **Enter** - Stay in confirmation mode (do nothing)

### Layout

The interface is divided into two sections:
- **Top 45%**: Preview window showing process details or confirmation dialog
- **Bottom 55%**: Scrollable port list for navigation

### What you'll see

#### Main Interface
The script displays a list of all listening ports with a dynamic header:

**Without auto-refresh:**
```
Use arrow keys to navigate, press 'K' to kill (with confirmation), 'Q' to quit | R: Manual refresh
```

**With auto-refresh:**
```
Use arrow keys to navigate, press 'K' to kill (with confirmation), 'Q' to quit | Auto-refresh: 5s | R: Manual refresh
```

The port list shows:
```
tcp4  0  0  *.3000     *.*     LISTEN
tcp6  0  0  *.8080     *.*     LISTEN
tcp4  0  0  127.0.0.1.5432  *.*     LISTEN
```

The preview window shows detailed process information including:
- Process ID (PID)
- Command that started the process
- User running the process
- Full network connection details

#### Enhanced Confirmation Mode
When killing a process, you'll see a beautifully formatted confirmation dialog:
```
═══════════════════════════════════════════════════════════════
CONFIRM KILL PROCESS ON PORT 3000
═══════════════════════════════════════════════════════════════
COMMAND   PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
node    12345  user   20u  IPv4  0x1234567      0t0  TCP *:3000 (LISTEN)

┌─ AVAILABLE ACTIONS ─────────────────────────────────────────┐
│ Y: Kill the process and return to main interface            │
│ N: Cancel and return to main interface                      │
│ Q: Quit the program                                         │
│ Enter: Do nothing (stay in confirmation mode)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### After Killing a Process
```
Successfully killed process with PID 12345 on port 3000.

Port list will reload automatically...
```

## Advanced Features

### Auto-Refresh Behavior
- **Smart Preview Persistence**: When in confirmation mode, the dialog stays visible during auto-refresh (unless the port is killed)
- **Automatic Port Detection**: If a port is killed, the confirmation dialog automatically closes
- **Immediate Feedback**: Port list reloads immediately after killing any process

### Cross-Platform Compatibility
- **No External Dependencies**: Uses only standard Unix commands (no timeout command needed)
- **macOS Optimized**: Works perfectly on macOS without requiring GNU coreutils
- **Linux Compatible**: Full support for all major Linux distributions

## How It Works

1. **Command Line Parsing**: Processes command line options for auto-refresh configuration
2. **Port Discovery**: Uses `netstat -anv` to find all listening ports
3. **Interactive Selection**: Pipes results to `fzf` with intelligent preview handling
4. **Auto-Refresh Logic**: Optional background monitoring with configurable intervals
5. **Process Identification**: Uses `lsof` to find processes using the selected port
6. **Enhanced Confirmation**: Shows detailed process information with professional UI
7. **Safe Termination**: Kills processes with `kill -9` and provides immediate feedback
8. **Automatic Reload**: Refreshes port list immediately after successful kills
9. **State Management**: Maintains UI state during auto-refresh cycles

## Error Handling

The script includes comprehensive error handling:

- ✅ Checks for fzf installation and provides installation instructions
- ✅ Validates command line arguments and shows usage help
- ✅ Validates port numbers are numeric
- ✅ Handles cases where no process is found on a port
- ✅ Provides feedback on successful/failed kill operations
- ✅ Uses appropriate shell environment for cross-shell compatibility
- ✅ Graceful cleanup of background processes and temporary files
- ✅ Smart handling of process termination and timeout scenarios

## Compatibility

- **macOS** - Fully supported (tested on macOS 10.15+)
- **Linux** - Fully supported (Ubuntu, Debian, RHEL, CentOS, Fedora, Amazon Linux)
- **Windows** - Not supported (requires WSL or similar Unix environment)

## Contributing

Feel free to submit issues or pull requests to improve the script!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 DARKHORSEONE LIMITED

## Troubleshooting

**"fzf not found" error:**
- Install fzf using the instructions provided by the script

**"No process found" message:**
- The port might not be in use anymore
- Try refreshing the list manually with R or wait for auto-refresh

**Permission denied when killing process:**
- You might need to run the script with `sudo` for system processes
- Some processes might be owned by other users

**Auto-refresh not working:**
- Make sure you're using the `--auto-refresh` or `-a` flag
- Check that the interval is set correctly with `-i N`

**Script doesn't work in certain shells:**
- The script is designed to work with bash and handles shell compatibility automatically

**Confirmation dialog disappears during auto-refresh:**
- This is normal behavior if the port was killed by another process
- The script automatically detects when ports are no longer available 