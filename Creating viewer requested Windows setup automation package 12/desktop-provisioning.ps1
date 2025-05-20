param(
    [switch]$SkipUpgrade
)

if ($SkipUpgrade) {
    Write-Host 'Will skip windows upgrade'
}

# Wait for network
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

# Setup Windows Update
$nuget = Get-PackageProvider 'NuGet' -ListAvailable -ErrorAction SilentlyContinue

if ($null -eq $nuget) {
    Install-PackageProvider -Name NuGet -Confirm:$false -Force
}

$module = Get-Module 'PSWindowsUpdate' -ListAvailable

if ($null -eq $module) {
    Install-Module PSWindowsUpdate -Confirm:$false -Force
}
# Install Windows Updates
$updates = Get-WindowsUpdate

if ($null -ne $updates) {
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | select KB, Result, Title, Size
}

$status = Get-WURebootStatus -Silent

if ($status) {
    if ($SkipUpgrade) {
        $setup_runonce = @{
            Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
            Name  = "execute_provisioning"
            Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-provisioning.ps1 -SkipUpgrade"
        }
    }
    else {
        $setup_runonce = @{
            Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
            Name  = "execute_provisioning"
            Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-provisioning.ps1"
        }
    }
    
    New-ItemProperty @setup_runonce | Out-Null
    Restart-Computer
}
else {
    if (!$SkipUpgrade) {
        # Figure out Windows version and if version is less than 10.0.26100 setup for upgrade
        $get_windows_version = @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        }
        $windows_version = gp @get_windows_version

        [version]$windows_version = "{0}.{1}.{2}.{3}" -f $windows_version.CurrentMajorVersionNumber, $windows_version.CurrentMinorVersionNumber, $windows_version.CurrentBuildNumber, $windows_version.UBR

        if ($windows_version -lt [version]'10.0.26100') {
            $setup_runonce = @{
                Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
                Name  = "execute_provisioning"
                Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-upgrade.ps1"
            }
            New-ItemProperty @setup_runonce | Out-Null
        }
        Restart-Computer   
    }
}

Write-Host "All Done!" -ForegroundColor Green
Read-Host