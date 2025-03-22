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
    $date = get-date
    $export_csv = @{
        Path              = "C:\ProgramData\provisioning\updateLog.csv"
        Encoding          = 'UTF8'
        NoTypeInformation = $true
        Append            = $true
    }
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | select KB, @{n = 'InstallDate'; e = { $date.ToString('yyyy.MM.dd') } }, Result, Title, Size | Export-Csv @export_csv
}

$status = Get-WURebootStatus -Silent

if ($status) {
    # Sign out Kiosk user
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

    # Configure Kiosk mode
    $cim_instance = Get-CimInstance @get_cim_instance
    $cim_instance.Configuration = [System.Net.WebUtility]::HtmlEncode($kiosk_configuration)
    Set-CimInstance -CimInstance $cim_instance

    # Pause Windows Updates for 30 days
    $pause_windows_update = @{
        Path  = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        Name  = 'PauseUpdatesExpiryTime'
        Value = (Get-Date).AddDays(30).ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
    }

    Set-ItemProperty @pause_windows_update

    Restart-Computer
}