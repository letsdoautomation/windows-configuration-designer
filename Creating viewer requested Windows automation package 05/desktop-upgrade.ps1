[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [String]$usb_drive_name,
    [Parameter(Mandatory = $True)]
    [System.IO.DirectoryInfo]$provisioning
)

$ProgressPreference_bk = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
do {
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if (!$ping) {
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while (!$ping)
$ProgressPreference = $ProgressPreference_bk

Write-Host "Starting compatibility check for Windows 11 upgrade"

$driveLetter = Get-Volume | ? { $_.FileSystemLabel -eq $usb_drive_name } | select -expand DriveLetter

$execute_upgrade_check = @{
    FilePath     = "{0}:\setup.exe" -f $driveLetter
    ArgumentList = "/auto upgrade", "/quiet", "/compat scanonly", "/eula accept"
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}

$upgrade_check = Start-Process @execute_upgrade_check

[bool]$canUpgrade = $false

switch ("{0:X}" -f $upgrade_check.ExitCode) {
    'C1900210' {
        Write-Host 'No compatibility issues found'
        $canUpgrade = $true
    }
    'C1900208' {
        Write-Host 'Actionable compatibility issues'
    }
    'C1900204' {
        Write-Host 'Mig-Choice selected is not available'
    }
    'C1900200' {
        Write-Host 'Machine is not eligible for Windows 10 or above'
    }
    'C190020E' {
        Write-Host 'Machine does not have enough free space to install'
    }
}

if ($canUpgrade) {
    Write-Host "Starting Windows upgrade"

    $execute_upgrade = @{
        FilePath     = "{0}:\setup.exe" -f $driveLetter
        ArgumentList = "/auto upgrade", "/dynamicupdate enable", "/quiet", "/eula accept", "/showoobe none", "/postoobe $($provisioning.FullName)\autologon.bat"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    Start-Process @execute_upgrade
} 
else {
    . "$($provisioning.FullName)\desktop-provisioning.ps1" -First -Provisioning $($provisioning.FullName)
}
