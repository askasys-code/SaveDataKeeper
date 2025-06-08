# Save Data Keeper

## Overview
`SaveDataKeeper.ps1` is a PowerShell script that provides a graphical user interface (GUI) for backing up files and folders specified in a configuration file (`paths.txt`). It offers two backup modes: a standard folder backup and a ZIP-compressed backup, both preserving the full folder structure from the drive root.

## Features
- **GUI Interface**: Built with Windows Forms, featuring buttons for initiating backups, browsing destinations, and opening the paths file.
- **Backup Paths**: Reads source paths from `paths.txt`, supporting absolute and relative paths (relative to the user's profile).
- **Standard Backup**: Copies files to a timestamped folder (e.g., `Backup_20250608_123456`) while maintaining the folder hierarchy (e.g., `Users\Username\Documents`).
- **ZIP Backup**: Stages files in a temporary directory with the same folder structure, then compresses them into a timestamped ZIP file (e.g., `Backup_20250608_123456.zip`).
- **DPI Scaling**: Adjusts the GUI for high-resolution monitors with manual DPI scaling.
- **Background Image**: Supports a custom background image (`background.jpg`) or falls back to a solid color.
- **Status Updates**: Displays real-time status messages during backup operations.

## Usage
1. Create a `paths.txt` file in the script's directory, listing paths to back up (one per line, ignoring comments with `#` or blank lines).
2. Run the script in PowerShell.
3. Use the GUI to:
   - Select a destination folder (defaults to the script's directory).
   - Click "Backup" for a standard folder backup.
   - Click "ZIP Backup" for a compressed ZIP backup.
   - Click "Open Paths File" to edit the configuration file.

## Requirements
- PowerShell 5.1 or later.
- Windows environment (for Windows Forms).
- Write permissions for the destination folder and temporary directory.

## Notes
- The script ensures both backup modes preserve the folder structure relative to the drive root.
- Temporary files for ZIP backups are cleaned up automatically.
- Error handling displays warnings for missing paths or files.

![Alt text](/screenshot/screenshot.jpg)
