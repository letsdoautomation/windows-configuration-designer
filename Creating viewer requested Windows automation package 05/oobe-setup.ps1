param(
    [Parameter(Mandatory = $True)]
    [string]$choco_executable,
    [Parameter(Mandatory = $True)]
    [string]$username,
    [Parameter(Mandatory = $True)]
    [string]$password,
    [string]$usb_name
)

$registry_settings = @()

# Create local user account for provisioning
$create_local_user = @{
    Name     = $username
    Password = (ConvertTo-SecureString -AsPlainText $password -Force)
}
$local_user = New-LocalUser @create_local_user 
$local_user | Set-LocalUser -PasswordNeverExpires $true 
$local_user | Add-LocalGroupMember -Group "Administrators"
<# 
# Configure autologon for provisioning user
$registry_settings +=
[PSCustomObject]@{ # Enable autologon
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "AutoAdminLogon"
    Value = "1"
},
[PSCustomObject]@{ # Set autologon username
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultUserName"
    Value = $username
},
[PSCustomObject]@{ # Set autologon password
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultPassword"
    Value = $password
}
 #>
# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Name -ne $choco_executable } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Install chocolatey
$install_chocolatey = @{
    FilePath     = "$($env:SystemRoot)\system32\msiexec.exe"
    ArgumentList = "/i {0}\$($choco_executable) /qn /norestart" -f (gl).path
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}
Start-Process @install_chocolatey | out-null

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

$registry_settings +=
[PSCustomObject]@{ # Skip privacy experiance menu
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
},
[PSCustomObject]@{ # Disable widgets
    Path  = "SOFTWARE\Policies\Microsoft\Dsh"
    Value = 0
    Name  = "AllowNewsAndInterests"
}

# If Windows 10
if ((gwmi Win32_OperatingSystem).Caption.Contains('Windows 10')) {
    $registry_settings += [PSCustomObject]@{ # Execute desktop-upgrade.ps1 using RunOnce
        Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_windows10_upgrade"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-upgrade.ps1 -provisioning $($provisioning.FullName) -usb_name $($usb_name) -username $($username) -password $($password)"
    }
}
# If anything else
else {
    $registry_settings += [PSCustomObject]@{ # Execute desktop-provisioning.ps1 using RunOnce
        Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-provisioning.ps1 -provisioning $($provisioning.FullName) -first -username $($username) -password $($password)"
    }
}

# Apply registry settings
foreach ($setting in ($registry_settings | group Path)) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        if (!$_.Type) {
            $registry.SetValue($_.name, $_.value)
        }
        else {
            $registry.SetValue($_.name, $_.value, $_.type)
        }
    }
    $registry.Dispose()
}