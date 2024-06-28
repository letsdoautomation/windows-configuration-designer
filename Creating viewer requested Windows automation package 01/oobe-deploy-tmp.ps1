param(
    [string]$ArchivePackageName,
    [System.IO.DirectoryInfo]$Destination
)

# Prepare destination directory
if (!$Destination.Exists) {
    $Destination.Create()
}

Set-MpPreference -ExclusionPath $Destination.FullName

# Copy archive to C:\Windows\temp otherwise extaction will fail in OOBE
$copy = @{
    Path        = "{0}\{1}" -f (gl).path, $ArchivePackageName
    Destination = "$($env:TEMP)\{0}" -f $ArchivePackageName
    Force       = $true
}

cp @copy

# Extract
$deploy_tmp_files = @{
    FilePath     = "$($env:TEMP)\{0}" -f $ArchivePackageName
    ArgumentList = "-y -o{0}" -f $Destination.FullName
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}

Start-Process @deploy_tmp_files

# Create desktop shortcut
$shell = New-Object -comObject WScript.Shell
$shortcut = $shell.CreateShortcut("$($env:PUBLIC)\Desktop\BackupUSB.lnk")
$shortcut.TargetPath = "{0}\RobocopyBackup.bat" -f $Destination.FullName
$shortcut.IconLocation = "imageres.dll,112"
# More built-in icons: https://github.com/letsdoautomation/chocolatey/blob/main/Deploy%20files%20and%20shortcuts%20with%20choco/icons.md
$shortcut.Save()