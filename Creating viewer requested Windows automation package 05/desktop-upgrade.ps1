[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [System.IO.DirectoryInfo]$provisioning,
    [Parameter(Mandatory = $True)]
    [String]$usb_name,
    [string]$username,
    [Parameter(Mandatory = $True)]
    [string]$password
)

# Wait for internet connection
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

$drive_letter = Get-Volume | ? { $_.FileSystemLabel -eq $usb_name } | select -expand DriveLetter

if ($null -ne $drive_letter) {
    $execute_compatibility_check = @{
        FilePath     = "$($drive_letter):\setup.exe"
        ArgumentList = "/auto upgrade", "/quiet", "/compat scanonly", "/eula accept"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    
    $compatibility_check = Start-Process @execute_compatibility_check

    switch ("{0:X}" -f $compatibility_check.ExitCode) {
        'C1900210' {
            Write-Host 'No compatibility issues found'
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
}
$autologon_bat =
@"
@echo off
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d "1" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /d "{0}" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /d "{1}" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v execute_provisioning /d "cmd /c powershell.exe -ExecutionPolicy Bypass -File {2}\desktop-provisioning.ps1 -First -Provisioning {2} -username {0} -password {1}" /f
"@ -f $username, $password, $provisioning.FullName

if (("{0:X}" -f $compatibility_check.ExitCode) -eq 'C1900210') {
    # Create autologon.bat file in provisioning folder
    $autologon_bat | Out-File "$($provisioning.FullName)\autologon.bat" -Encoding ASCII

    # Execute upgrade to Windows 11
    Write-Host "Starting windows upgrade"
    $execute_upgrade = @{
        FilePath     = "$($drive_letter):\setup.exe"
        ArgumentList = "/auto upgrade", "/dynamicupdate enable", "/quiet", "/eula accept", "/showoobe none", "/postoobe $($provisioning.FullName)\autologon.bat"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    Start-Process @execute_upgrade | Out-Null
}
else {
    . "$($provisioning.FullName)\desktop-provisioning.ps1" -first -provisioning $provisioning.FullName -username $username -password $password
}