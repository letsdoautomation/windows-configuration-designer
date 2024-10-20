$usb_drive_name = 'ESD-USB'
$provisioning_user_password = 'password55'
$chocolatey_msi_file = "chocolatey-2.3.0.0.msi"

# Create local provisioning account
$local_user = @{
    Name     = 'provisioning'
    Password = (ConvertTo-SecureString -AsPlainText $provisioning_user_password -Force)
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Name -notlike "chocolatey*" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Install chocolatey
$install_chocolatey = @{
    FilePath         = '{0}\system32\msiexec.exe' -f $env:SystemRoot
    ArgumentList     = '/i "{0}\{1}" /qn /norestart' -f (gl).path, $chocolatey_msi_file
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_chocolatey

# Create user registry settings file
# Taskbar settings
$user_registry_settings = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000
"TaskbarAl"=dword:00000000
"ShowCopilotButton"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"@

$user_registry_settings | Out-File "$($provisioning.FullName)\desktop-user-registry.reg" -Encoding unicode

# Configure power settings
"powercfg /x -monitor-timeout-ac 0",
"powercfg /x -standby-timeout-ac 0",
"powercfg /x -hibernate-timeout-ac 0",
"powercfg /x -monitor-timeout-dc 0",
"powercfg /x -standby-timeout-dc 0",
"powercfg /x -hibernate-timeout-dc 0",
"powercfg /setACvalueIndex scheme_current sub_buttons lidAction 0",
"powercfg /setDCvalueIndex scheme_current sub_buttons lidAction 0",
"powercfg /setActive scheme_current" | % {
    cmd /c $_
}

$settings = @()

$settings +=
[PSCustomObject]@{ # Skip privacy experiance
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
},
[PSCustomObject]@{ # Disable widgets
    Path  = "SOFTWARE\Policies\Microsoft\Dsh"
    Value = 0
    Name  = "AllowNewsAndInterests"
},
[PSCustomObject]@{ # Configure autologon for provisioning user
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "AutoAdminLogon"
    Value = "1"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultUserName"
    Value = "provisioning"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultPassword"
    Value = $provisioning_user_password
}

$autologon_bat = @"
@echo off
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d "1" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /d "provisioning" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /d "{0}" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v execute_provisioning /d "cmd /c powershell.exe -ExecutionPolicy Bypass -File {1}\desktop-provisioning.ps1 -First -Provisioning {1}" /f
"@ -f $provisioning_user_password, $provisioning.FullName

if ((Get-WmiObject Win32_OperatingSystem).Caption -match "Windows 10") {
    # IF Windows 10
    $settings += [PSCustomObject]@{ # Execute desktop-upgrade.ps1 using RunOnce
        Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_windows10_upgrade"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-upgrade.ps1 -usb_drive_name {1} -provisioning {0}" -f $provisioning.FullName, $usb_drive_name
    }

    $autologon_bat | Out-File "$($provisioning.FullName)\autologon.bat" -Encoding ASCII
}
else {
    # IF Everything else
    $settings += [PSCustomObject]@{ # Execute desktop-provisioning.ps1 using RunOnce
        Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-provisioning.ps1 -First -Provisioning {0}" -f $provisioning.FullName
    }
}

$settings = $settings | group Path

foreach ($setting in $settings) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}