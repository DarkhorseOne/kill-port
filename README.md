# Kill Port

A simple interactive command-line tool to find and kill processes running on specific ports using [fzf](https://github.com/junegunn/fzf) for a fuzzy-finding interface.

## Features

- 🔍 **Interactive port browsing** - View all listening ports with a fuzzy-finder interface
- 👀 **Process preview** - See detailed process information before taking action
- ⚡ **Quick kill** - Kill processes with a simple keystroke
- 🛡️ **Safety checks** - Validates ports and handles errors gracefully
- 🖥️ **Cross-platform** - Works on macOS and Linux

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

Run the script from your terminal:

```bash
./kill-port.sh
```

Or if installed globally:

```bash
kill-port
```

### Interface Controls

- **Arrow keys** - Navigate through the list of listening ports
- **Enter** - Select and view process details
- **K key** - Kill the selected process
- **Esc/Ctrl+C** - Exit the application

### What you'll see

The script displays a list of all listening ports in this format:
```
tcp4  0  0  *.3000     *.*     LISTEN
tcp6  0  0  *.8080     *.*     LISTEN
```

The preview window shows detailed process information including:
- Process ID (PID)
- Command that started the process
- User running the process
- Full network connection details

## Example Output

```
┌─────────────────────────────────────────────────────────────┐
│ COMMAND   PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME │
│ node    12345  user   20u  IPv4  0x1234567      0t0  TCP     │
│ *:3000 (LISTEN)                                              │
└─────────────────────────────────────────────────────────────┘
```

## How It Works

1. **Port Discovery**: Uses `netstat -anv` to find all listening ports
2. **Interactive Selection**: Pipes the results to `fzf` for interactive browsing
3. **Process Identification**: Uses `lsof` to find processes using the selected port
4. **Safe Termination**: Kills processes with `kill -9` and provides feedback

## Error Handling

The script includes comprehensive error handling:

- ✅ Checks for fzf installation and provides installation instructions
- ✅ Validates port numbers are numeric
- ✅ Handles cases where no process is found on a port
- ✅ Provides feedback on successful/failed kill operations
- ✅ Uses appropriate shell environment for cross-shell compatibility

## Compatibility

- **macOS** - Fully supported
- **Linux** - Fully supported
- **Windows** - Not supported (requires WSL or similar Unix environment)

## Contributing

Feel free to submit issues or pull requests to improve the script!

## License

This project is open source. Feel free to use and modify as needed.

## Troubleshooting

**"fzf not found" error:**
- Install fzf using the instructions provided by the script

**"No process found" message:**
- The port might not be in use anymore
- Try refreshing the list by rerunning the script

**Permission denied when killing process:**
- You might need to run the script with `sudo` for system processes
- Some processes might be owned by other users

**Script doesn't work in certain shells:**
- The script is designed to work with bash and handles shell compatibility automatically 