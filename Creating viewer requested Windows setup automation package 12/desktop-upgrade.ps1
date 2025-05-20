$usb_name = "ESD-USB"

@"
@echo off
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v execute_provisioning /d "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-provisioning.ps1 -SkipUpgrade" /f
"@ | Out-File "$($env:ProgramData)\provisioning\execute_provisioning.bat" -Encoding ASCII

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

if (("{0:X}" -f $compatibility_check.ExitCode) -eq 'C1900210') {
    # Execute upgrade
    Write-Host "Starting windows upgrade"
    $execute_upgrade = @{
        FilePath     = "$($drive_letter):\setup.exe"
        ArgumentList = "/auto upgrade", "/dynamicupdate enable", "/quiet", "/eula accept", "/showoobe none", "/postoobe $($env:ProgramData)\provisioning\execute_provisioning.bat", "/copylogs $($env:TEMP)\WindowsUpgradeLog.log"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    Start-Process @execute_upgrade | Out-Null
}

Read-Host