# Import required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pathsFile = Join-Path $scriptDir "paths.txt"
$defaultDestination = $scriptDir # Set default destination to script's directory
$backgroundImagePath = Join-Path $scriptDir "background.jpg" # Change to .png if needed

# Function to read source paths from file
function Get-SourcePaths {
    if (-not (Test-Path $pathsFile)) {
        throw "File $pathsFile not found. Please create it with the list of paths to backup."
    }
    
    $paths = Get-Content $pathsFile | Where-Object {
        $_ -and $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
    } | ForEach-Object { $_.Trim() }
    
    $sourcePaths = @()
    foreach ($path in $paths) {
        if ([System.IO.Path]::IsPathRooted($path)) {
            $sourcePaths += $path
        } else {
            $sourcePaths += Join-Path $env:USERPROFILE $path
        }
    }
    
    return $sourcePaths
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "SAVE DATA KEEPER"

# Manual DPI scaling for high-resolution monitors (assuming 150% scaling for 144 DPI)
$dpiScale = 1.2 # Adjust based on DPI settings (e.g., 1.25 for 120 DPI, 1.5 for 144 DPI, 2.0 for 192 DPI)
$baseWidth = 800
$baseHeight = 600
$form.Size = New-Object System.Drawing.Size([math]::Round($baseWidth * $dpiScale), [math]::Round($baseHeight * $dpiScale))

$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Set background image or fallback to solid color
try {
    if (Test-Path $backgroundImagePath) {
        $form.BackgroundImage = [System.Drawing.Image]::FromFile($backgroundImagePath)
        $form.BackgroundImageLayout = "Stretch" # Scale image to fit form
    } else {
        $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    }
} catch {
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    Write-Warning "Failed to load background image: $($_.Exception.Message)"
}
$form.ForeColor = [System.Drawing.Color]::White

# Scale font size based on DPI
$baseFontSize = 10
$scaledFontSize = [math]::Round($baseFontSize * $dpiScale)
$form.Font = New-Object System.Drawing.Font("Cascadia Code", $scaledFontSize)

# Create semi-transparent panel for controls
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point([math]::Round(10 * $dpiScale), [math]::Round(10 * $dpiScale))
$panel.Size = New-Object System.Drawing.Size([math]::Round(760 * $dpiScale), [math]::Round(560 * $dpiScale))
$panel.BackColor = [System.Drawing.Color]::FromArgb(200, 30, 30, 30) # Semi-transparent dark background
$form.Controls.Add($panel) # Add panel to form early

# Create controls
$lblSource = New-Object System.Windows.Forms.Label
try {
    $sourcePaths = Get-SourcePaths
    $lblSource.Text = "Save Data: $($sourcePaths.Count)"
} catch {
    $lblSource.Text = "Error: $_"
}
$lblSource.Location = New-Object System.Drawing.Point([math]::Round(10 * $dpiScale), [math]::Round(10 * $dpiScale))
$lblSource.Size = New-Object System.Drawing.Size([math]::Round(550 * $dpiScale), [math]::Round(30 * $dpiScale))
$lblSource.BackColor = [System.Drawing.Color]::Transparent
$lblSource.ForeColor = [System.Drawing.Color]::LightGray
$lblSource.AutoSize = $true

$btnOpenPathsFile = New-Object System.Windows.Forms.Button
$btnOpenPathsFile.Text = "Open Paths File"
$btnOpenPathsFile.Location = New-Object System.Drawing.Point([math]::Round(400 * $dpiScale), [math]::Round(8 * $dpiScale))
$btnOpenPathsFile.Size = New-Object System.Drawing.Size([math]::Round(150 * $dpiScale), [math]::Round(26 * $dpiScale))
$btnOpenPathsFile.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnOpenPathsFile.ForeColor = [System.Drawing.Color]::White
$btnOpenPathsFile.FlatStyle = "Flat"

$lblDestination = New-Object System.Windows.Forms.Label
$lblDestination.Text = "Destination Folder:"
$lblDestination.Location = New-Object System.Drawing.Point([math]::Round(10 * $dpiScale), [math]::Round(60 * $dpiScale))
$lblDestination.Size = New-Object System.Drawing.Size([math]::Round(120 * $dpiScale), [math]::Round(20 * $dpiScale))
$lblDestination.BackColor = [System.Drawing.Color]::Transparent
$lblDestination.ForeColor = [System.Drawing.Color]::LightGray

$txtDestination = New-Object System.Windows.Forms.TextBox
$txtDestination.Text = $defaultDestination
$txtDestination.Location = New-Object System.Drawing.Point([math]::Round(140 * $dpiScale), [math]::Round(58 * $dpiScale))
$txtDestination.Size = New-Object System.Drawing.Size([math]::Round(350 * $dpiScale), [math]::Round(24 * $dpiScale))
$txtDestination.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$txtDestination.ForeColor = [System.Drawing.Color]::White
$txtDestination.BorderStyle = "FixedSingle"

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Set..."
$btnBrowse.Location = New-Object System.Drawing.Point([math]::Round(500 * $dpiScale), [math]::Round(56 * $dpiScale))
$btnBrowse.Size = New-Object System.Drawing.Size([math]::Round(60 * $dpiScale), [math]::Round(26 * $dpiScale))
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnBrowse.ForeColor = [System.Drawing.Color]::White
$btnBrowse.FlatStyle = "Flat"

$btnBackup = New-Object System.Windows.Forms.Button
$btnBackup.Text = "Backup"
$btnBackup.Location = New-Object System.Drawing.Point([math]::Round(10 * $dpiScale), [math]::Round(100 * $dpiScale))
$btnBackup.Size = New-Object System.Drawing.Size([math]::Round(120 * $dpiScale), [math]::Round(36 * $dpiScale))
$btnBackup.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnBackup.ForeColor = [System.Drawing.Color]::White
$btnBackup.FlatStyle = "Flat"

$btnZipBackup = New-Object System.Windows.Forms.Button
$btnZipBackup.Text = "ZIP Backup"
$btnZipBackup.Location = New-Object System.Drawing.Point([math]::Round(140 * $dpiScale), [math]::Round(100 * $dpiScale))
$btnZipBackup.Size = New-Object System.Drawing.Size([math]::Round(120 * $dpiScale), [math]::Round(36 * $dpiScale))
$btnZipBackup.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnZipBackup.ForeColor = [System.Drawing.Color]::White
$btnZipBackup.FlatStyle = "Flat"

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status: Ready"
$lblStatus.Location = New-Object System.Drawing.Point([math]::Round(10 * $dpiScale), [math]::Round(150 * $dpiScale))
$lblStatus.Size = New-Object System.Drawing.Size([math]::Round(550 * $dpiScale), [math]::Round(100 * $dpiScale))
$lblStatus.BackColor = [System.Drawing.Color]::Transparent
$lblStatus.ForeColor = [System.Drawing.Color]::LightGray
$lblStatus.AutoSize = $false

# Event Handlers
# Open Paths File button click event
$btnOpenPathsFile.Add_Click({
    try {
        if (Test-Path $pathsFile) {
            Invoke-Item $pathsFile # Opens the file with its default associated application
        } else {
            [System.Windows.Forms.MessageBox]::Show("The 'backup_paths.txt' file was not found.", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error opening file: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Browse button click event
$btnBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select backup destination folder"
    $folderBrowser.SelectedPath = $txtDestination.Text # Set initial selected path to current text box value
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtDestination.Text = $folderBrowser.SelectedPath
    }
})

# Normal Backup button click event
$btnBackup.Add_Click({
    $destination = $txtDestination.Text
    $lblStatus.Text = "Status: Backup in progress..."
    $btnBackup.Enabled = $false
    $btnZipBackup.Enabled = $false
    $btnBrowse.Enabled = $false
    $btnOpenPathsFile.Enabled = $false
    $form.Refresh()
    
    try {
        $sourcePaths = Get-SourcePaths
        
        # Create destination folder if it doesn't exist
        if (-not (Test-Path $destination)) {
            New-Item -Path $destination -ItemType Directory -Force | Out-Null
        }
        
        # Create timestamp for backup folder
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupRoot = Join-Path $destination "Backup_$timestamp"
        New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
        
        # Backup each source folder
        foreach ($source in $sourcePaths) {
            if (Test-Path $source) {
                # Get the full resolved path
                $fullSourcePath = (Resolve-Path $source).Path
                
                # Extract the drive name (e.g., "C:") and the relative path from the drive
                $drive = [System.IO.Path]::GetPathRoot($fullSourcePath) # e.g., "C:\"
                $relativePath = $fullSourcePath.Substring($drive.Length) # e.g., "Users\Username\Documents"
                
                # Construct the destination path preserving the structure from the drive
                $destPath = Join-Path $backupRoot $relativePath
                
                # Create the folder structure in the destination
                $parentDestPath = Split-Path $destPath -Parent
                if (-not (Test-Path $parentDestPath)) {
                    New-Item -Path $parentDestPath -ItemType Directory -Force | Out-Null
                }
                
                # Copy files while preserving the folder structure
                Copy-Item -Path $source -Destination $destPath -Recurse -Force
                $lblStatus.Text = "Status: Backed up '$source'"
                $form.Refresh()
            } else {
                $lblStatus.Text = "Status: Warning - Source path not found: '$source'"
                $form.Refresh()
            }
        }
        
        $lblStatus.Text = "Status: Backup completed successfully at '$backupRoot'"
    } catch {
        $lblStatus.Text = "Status: Error occurred - $($_.Exception.Message)"
    } finally {
        $btnBackup.Enabled = $true
        $btnZipBackup.Enabled = $true
        $btnBrowse.Enabled = $true
        $btnOpenPathsFile.Enabled = $true
    }
})

# ZIP Backup button click event
$btnZipBackup.Add_Click({
    $destination = $txtDestination.Text
    $lblStatus.Text = "Status: ZIP Backup in progress..."
    $btnBackup.Enabled = $false
    $btnZipBackup.Enabled = $false
    $btnBrowse.Enabled = $false
    $btnOpenPathsFile.Enabled = $false
    $form.Refresh()
    
    try {
        $sourcePaths = Get-SourcePaths
        
        # Create destination folder if it doesn't exist
        if (-not (Test-Path $destination)) {
            New-Item -Path $destination -ItemType Directory -Force | Out-Null
        }
        
        # Create timestamp for ZIP file (YYYYMMDD_HHmmss for uniqueness)
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $zipFileName = "Backup_$timestamp.zip"
        $zipFilePath = Join-Path $destination $zipFileName
        
        # Create a temporary directory for staging
        $tempDir = Join-Path $env:TEMP "BackupStaging_$timestamp"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force | Out-Null
        }
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
        
        try {
            # Copy source folders to temporary directory, preserving relative structure from root
            foreach ($source in $sourcePaths) {
                if (Test-Path $source) {
                    # Get the full resolved path
                    $fullSourcePath = (Resolve-Path $source).Path
                    
                    # Extract the drive name (e.g., "C:") and the relative path from the drive
                    $drive = [System.IO.Path]::GetPathRoot($fullSourcePath) # e.g., "C:\"
                    $relativePath = $fullSourcePath.Substring($drive.Length) # e.g., "Users\Username\Documents"
                    
                    # Construct the staging path preserving the structure from the drive
                    $stagingPath = Join-Path $tempDir $relativePath
                    
                    # Create the folder structure in the temporary directory
                    $parentStagingPath = Split-Path $stagingPath -Parent
                    if (-not (Test-Path $parentStagingPath)) {
                        New-Item -Path $parentStagingPath -ItemType Directory -Force | Out-Null
                    }
                    
                    # Copy files to the staging path
                    Copy-Item -Path $fullSourcePath -Destination $stagingPath -Recurse -Force
                    $lblStatus.Text = "Status: Staged '$source' for compression"
                    $form.Refresh()
                } else {
                    $lblStatus.Text = "Status: Warning - Source path not found: '$source'"
                    $form.Refresh()
                }
            }
            
            # Compress the temporary directory contents into a single ZIP file
            if (Test-Path $zipFilePath) {
                Remove-Item -Path $zipFilePath -Force | Out-Null
            }
            Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFilePath -Force
            $lblStatus.Text = "Status: ZIP Backup compressed to '$zipFilePath'"
        } finally {
            # Clean up temporary directory
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force | Out-Null
            }
        }
    } catch {
        $lblStatus.Text = "Status: Error occurred - $($_.Exception.Message)"
    } finally {
        $btnBackup.Enabled = $true
        $btnZipBackup.Enabled = $true
        $btnBrowse.Enabled = $true
        $btnOpenPathsFile.Enabled = $true
    }
})

# Add controls to panel
$panel.Controls.AddRange(@(
    $lblSource,
    $btnOpenPathsFile,
    $lblDestination,
    $txtDestination,
    $btnBrowse,
    $btnBackup,
    $btnZipBackup,
    $lblStatus
))

# Show the form
[void]$form.ShowDialog()