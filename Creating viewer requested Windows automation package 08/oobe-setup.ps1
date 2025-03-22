# Set password never expires for admin user
$configure_admin = @{
    name                 = 'admin'
    PasswordNeverExpires = $true
}
Set-LocalUser @configure_admin

# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Deploy C:\Kiosk\ files
$deploy_kiosk_files = @{
    FilePath     = "$($provisioning.FullName)\index.exe"
    ArgumentList = '-y -o"C:\Kiosk\"'
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}

Start-Process @deploy_kiosk_files

# Configure Kiosk mode
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

$get_cim_instance = @{
    Namespace = "root\cimv2\mdm\dmmap"
    ClassName = "MDM_AssignedAccess"
}

$cim_instance = Get-CimInstance @get_cim_instance
$cim_instance.Configuration = [System.Net.WebUtility]::HtmlEncode($kiosk_configuration)
Set-CimInstance -CimInstance $cim_instance

# Configure scheduled task for Windows updates
$configure_scheduled_action = @{
    Execute  = "powershell.exe"
    Argument = "-ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-updates.ps1"
}

$configure_scheduled_trigger = @{
    Daily = $true
    At    = '3:00 AM'
}

$configure_scheduled_settings = @{
    WakeToRun = $true
}

$configure_scheduled_principal = @{
    UserId    = "SYSTEM"
    LogonType = 'ServiceAccount'
    RunLevel  = 'Highest'
}

$configure_scheduled_task = @{
    Action    = New-ScheduledTaskAction @configure_scheduled_action
    Principal = New-ScheduledTaskPrincipal @configure_scheduled_principal
    Trigger   = New-ScheduledTaskTrigger @configure_scheduled_trigger
    Settings  = New-ScheduledTaskSettingsSet @configure_scheduled_settings
}

$register_scheduled_task = @{
    TaskName    = "KIOSK Windows Updates"
    InputObject = New-ScheduledTask @configure_scheduled_task
}

Register-ScheduledTask @register_scheduled_task