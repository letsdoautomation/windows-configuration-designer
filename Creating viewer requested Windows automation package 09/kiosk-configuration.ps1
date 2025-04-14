$kiosk_configuration = 
@"
<?xml version="1.0" encoding="utf-8"?>
<AssignedAccessConfiguration xmlns="http://schemas.microsoft.com/AssignedAccess/2017/config" xmlns:rs5="http://schemas.microsoft.com/AssignedAccess/201810/config" xmlns:v4="http://schemas.microsoft.com/AssignedAccess/2021/config">
  <Profiles>
    <Profile Id="{EDB3036B-780D-487D-A375-69369D8A8F78}">
      <KioskModeApp v4:ClassicAppPath="%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" v4:ClassicAppArguments="--kiosk https://www.google.com/search?q=$($env:COMPUTERNAME) --edge-kiosk-type=public-browsing -kiosk-idle-timeout-minutes=0 --no-first-run" />
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

# Configure KIOSK mode

$get_cim_instance = @{
  Namespace = "root\cimv2\mdm\dmmap"
  ClassName = "MDM_AssignedAccess"
}
$cim_instance = Get-CimInstance @get_cim_instance
$cim_instance.Configuration = [System.Net.WebUtility]::HtmlEncode($kiosk_configuration)
Set-CimInstance -CimInstance $cim_instance