param(
    [System.IO.DirectoryInfo]$ProvisioningFolder
)

$chocolatey_packages =
'7zip.install',
'notepadplusplus.install',
'googlechrome',
'adobereader',
'teamviewer.host' -join " "

$software_packages = 
[PSCustomObject]@{
    Executable  = "{0}\setup.exe" -f $ProvisioningFolder.FullName
    Arguments   = "/configure {0}\{1}" -f $ProvisioningFolder.FullName, "Configuration.xml"
    NoNewWindow = $true
    PassThru    = $true
    Wait        = $true
}

# Install chocolatey packages
$install_software_packages = @{
    FilePath     = "C:\ProgramData\chocolatey\choco.exe"
    ArgumentList = "install {0} -y --no-progress --ignore-checksums" -f $chocolatey_packages
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}

Start-Process @install_software_packages

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

# Execute desktop-configure-taskbar.ps1
. "$($ProvisioningFolder.FullName)\desktop-configure-taskbar.ps1" -ProvisioningFolder $ProvisioningFolder
. "$($ProvisioningFolder.FullName)\desktop-application.ps1"

Write-Host "All Done!" -ForegroundColor Green
Read-Host