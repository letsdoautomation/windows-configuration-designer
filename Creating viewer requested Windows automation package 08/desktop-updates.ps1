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

$kiosk_configuration = @"
<?xml version="1.0" encoding="utf-8"?>
<AssignedAccessConfiguration xmlns="http://schemas.microsoft.com/AssignedAccess/2017/config" xmlns:rs5="http://schemas.microsoft.com/AssignedAccess/201810/config" xmlns:v4="http://schemas.microsoft.com/AssignedAccess/2021/config">
  <Profiles>
    <Profile Id="{EDB3036B-780D-487D-A375-69369D8A8F78}">
      <KioskModeApp v4:ClassicAppPath="%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" v4:ClassicAppArguments="--kiosk C:\kiosk\index.html --edge-kiosk-type=public-browsing -kiosk-idle-timeout-minutes=0 --no-first-run" />
    </Profile>
  </Profiles>
  <Configs>
    <Config>
      <AutoLogonAccount rs5:DisplayName="Kiosk" />
      <DefaultProfile Id="{EDB3036B-780D-487D-A375-69369D8A8F78}" />
    </Config>
  </Configs>
</AssignedAccessConfiguration>
"@

# Resume Windows Updates
$settings = 
[PSCustomObject]@{
    Name = 'PauseFeatureUpdatesEndTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PauseQualityUpdatesEndTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PauseUpdatesExpiryTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PauseFeatureUpdatesStartTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PauseQualityUpdatesStartTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PauseUpdatesStartTime'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
},
[PSCustomObject]@{
    Name = 'PausedFeatureDate'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings'
},
[PSCustomObject]@{
    Name = 'PausedQualityDate'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings'
},
[PSCustomObject]@{
    Name = 'PausedFeatureStatus'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings'
},
[PSCustomObject]@{
    Name = 'PausedQualityStatus'
    Path = 'SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings'
}

foreach ($setting in ($settings | group Path)) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        continue
    }

    foreach ($item in $setting.Group.Where({ $null -ne $registry.GetValue($_.name) })) {
        $registry.DeleteValue($item.name, $true)
    }
    $registry.Dispose()
}

# Setup Nuget and PSWindowsUpdate module for Windows Update
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

    $install_updates = @{
        AcceptAll    = $true
        Install      = $true
        IgnoreReboot = $true
    }
    $output = Install-WindowsUpdate @install_updates | select KB, @{n = 'InstallDate'; e = { $date.ToString('yyyy.MM.dd') } }, Result, Title, Size

    # Saves update installation log to csv file in C:\programdata\provisioning folder
    $date = get-date
    $export_csv = @{
        Path              = "C:\ProgramData\provisioning\updateLog.csv"
        Encoding          = 'UTF8'
        NoTypeInformation = $true
        Append            = $true
    }
    $output | Export-Csv @export_csv
}

$status = Get-WURebootStatus -Silent

# Pause Windows Updates for 30 days
$pause_for_days = 30

$date = Get-Date
    
$pause_start = $date.ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
$pause_end = $date.AddDays($pause_for_days).ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
    
$settings = 
foreach ($item in 'PauseFeatureUpdatesEndTime', 'PauseQualityUpdatesEndTime', 'PauseUpdatesExpiryTime') {
    [PSCustomObject]@{
        Path  = "SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
        Name  = $item
        Value = $pause_end
    }
}
    
$settings += 
foreach ($item in 'PauseFeatureUpdatesStartTime', 'PauseQualityUpdatesStartTime', 'PauseUpdatesStartTime') {
    [PSCustomObject]@{
        Path  = "SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
        Name  = $item
        Value = $pause_start
    }
}
    
$settings +=
foreach ($item in 'PausedFeatureDate', 'PausedQualityDate') {
    [PSCustomObject]@{
        Path  = "SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings"
        Name  = $item
        Value = $pause_start
    }
}
    
$settings +=
foreach ($item in 'PausedFeatureStatus', 'PausedQualityStatus') {
    [PSCustomObject]@{
        Path  = "SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings"
        Name  = $item
        Value = 1
    }
}
    
foreach ($setting in ($settings | group Path)) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}

if ($status) {
    # Sign out KIOSK user
    $process = get-process msedge -IncludeUserName | select UserName, SessionId -Unique

    $process | ? { $_.UserName -like "*kioskUser*" } | % {
        logoff $_.SessionId
    }

    # Remove KIOSK mode configuration
    $get_cim_instance = @{
        Namespace = "root\cimv2\mdm\dmmap"
        ClassName = "MDM_AssignedAccess"
    }

    $cim_instance = Get-CimInstance @get_cim_instance
    $cim_instance.Configuration = $null
    Set-CimInstance -CimInstance $cim_instance    

    # Configure KIOSK mode
    $cim_instance = Get-CimInstance @get_cim_instance
    $cim_instance.Configuration = [System.Net.WebUtility]::HtmlEncode($kiosk_configuration)
    Set-CimInstance -CimInstance $cim_instance

    Restart-Computer
}