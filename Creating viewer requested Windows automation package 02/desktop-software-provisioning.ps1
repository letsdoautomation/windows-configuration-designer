param(
    [System.IO.DirectoryInfo]$ProvisioningFolder
)

$software_packages = 
[PSCustomObject]@{
    Executable  = "{0}\setup.exe" -f "$($env:SystemRoot)\TEMP\m365"
    Arguments   = "/configure {0}\{1}" -f "$($env:SystemRoot)\TEMP\m365", "Configuration.xml"
    NoNewWindow = $true
    PassThru    = $true
    Wait        = $true
}

foreach ($package in $software_packages) {

    Write-Host "Executing: $($package.Executable) ExitCode: " -NoNewline

    if ([System.IO.Path]::GetExtension($package.Executable) -eq '.msi') {
        $execute = @{
            FilePath     = "msiexec"
            ArgumentList = "/i {0} {1}" -f $package.Executable, $package.Arguments
            PassThru     = $true
            Wait         = $true
        }
    }
    elseif ([System.IO.Path]::GetExtension($package.Executable) -eq '.exe') {
        $execute = @{
            FilePath     = $package.Executable
            ArgumentList = $package.Arguments
            PassThru     = $true
            Wait         = $true
        }
    }
    $p = Start-Process @execute

    Write-Host $p.exitcode
}

# Execute desktop-configure-taskbar.ps1, desktop-shortcuts.ps1, netplwiz
. "$($ProvisioningFolder.FullName)\desktop-configure-taskbar.ps1" -ProvisioningFolder $ProvisioningFolder
. "$($ProvisioningFolder.FullName)\desktop-shortcuts.ps1"
netplwiz

Write-Host "All Done!" -ForegroundColor Green
Read-Host