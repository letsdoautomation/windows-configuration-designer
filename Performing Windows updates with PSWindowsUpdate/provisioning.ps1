$ProgressPreference_bk = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
# Wait for network
do{
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if(!$ping){
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while(!$ping)
$ProgressPreference = $ProgressPreference_bk

##
# Windows Update part
##
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

if($status){
    $setup_runonce = @{
        Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name = "execute_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\provisioning.ps1" -f "$($env:ProgramData)\provisioning"
    }
    New-ItemProperty @setup_runonce | Out-Null
    Restart-Computer
}

Write-Host "All Done!" -ForegroundColor Green
Read-Host