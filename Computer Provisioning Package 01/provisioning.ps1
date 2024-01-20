param(
    [switch]$first
)

$provisioning = [System.IO.DirectoryInfo]"$($env:ProgramData)\provisioning"

# run computer/software configuration scripts
if ($first) {
    . "$($provisioning.FullName)\configure_brave.ps1"
    . "$($provisioning.FullName)\configure_chrome.ps1"
    . "$($provisioning.FullName)\configure_edge.ps1"
    . "$($provisioning.FullName)\configure_firefox.ps1"
}

# wait for network
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

if ($first) {
    # setup windows update powershell module
    $nuget = Get-PackageProvider 'NuGet' -ListAvailable -ErrorAction SilentlyContinue

    if ($null -eq $nuget) {
        Install-PackageProvider -Name NuGet -Confirm:$false -Force
    }

    $module = Get-Module 'PSWindowsUpdate' -ListAvailable

    if ($null -eq $module) {
        Install-Module PSWindowsUpdate -Confirm:$false -Force
    }
}

# install windows updates
$updates = Get-WindowsUpdate

if ($null -ne $updates) {
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | select KB, Result, Title, Size
}

$status = Get-WURebootStatus -Silent

if ($status) {
    $setup_runonce = @{
        Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\provisioning.ps1" -f "$($env:ProgramData)\provisioning"
    }
    New-ItemProperty @setup_runonce | Out-Null
    Restart-Computer
}
else {
    # chocolatey software installation
    $driveLetter = Get-Volume | ? { $_.FileSystemLabel -eq "New Volume" } | select -expand DriveLetter

    $packages =
    [PSCustomObject]@{
        Name   = "firefox"
        Source = "community"
    },
    [PSCustomObject]@{
        Name   = "googlechrome"
        Source = "community"
    },
    [PSCustomObject]@{
        Name   = "brave"
        Source = "usb"
    }

    foreach ($package in $packages) {
        if ($package.Source -eq 'usb') {
            choco install $package.Name -s "$($driveLetter):\choco" -y --no-progress --ignore-checksums
        }
        else {
            choco install $package.Name -y --no-progress --ignore-checksums
        }
    }


    do {
        "Availabe actions:",
        "   1 - Create local admin account",
        "   2 - Change computer name",
        "   3 - Restart computer",
        "   0 - Close script" | Out-Host
        $selected = Read-Host "Enter selection"
        switch ($selected) {
            1 {
                Get-Credential | select @{n = 'Name'; e = { $_.UserName } },
                @{n = 'Password'; e = { $_.Password } } | New-LocalUser -PasswordNeverExpires | Add-LocalGroupMember -Group "Administrators"
                break
            }
            2 {
                Read-Host "Enter computer name" | select @{n = 'NewName'; e = { $_ } } | Rename-Computer
                break
            }
            3 {
                Restart-Computer
                break
            }
        }
    }while ($selected -ne 0)

    # best place to add more actions
    Write-Host "All Done!" -ForegroundColor Green
    Read-Host
}