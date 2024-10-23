param(
    [Parameter(Mandatory = $True)]
    [string]$local_username,
    [Parameter(Mandatory = $True)]
    [string]$local_password,
    [Parameter(Mandatory = $True)]
    [string]$domain_username,
    [Parameter(Mandatory = $True)]
    [string]$domain_password
)

$registry_settings = @()

# Create local user account for provisioning
$create_local_user = @{
    Name     = $local_username
    Password = (ConvertTo-SecureString -AsPlainText $local_password -Force)
}
$local_user = New-LocalUser @create_local_user 
$local_user | Set-LocalUser -PasswordNeverExpires $true 
$local_user | Add-LocalGroupMember -Group "Administrators"

$registry_settings +=
[PSCustomObject]@{ # Skip privacy experiance menu
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
},
[PSCustomObject]@{ # Enable autologon
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "AutoAdminLogon"
    Value = "1"
},
[PSCustomObject]@{ # Set autologon username
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultUserName"
    Value = $local_username
},
[PSCustomObject]@{ # Set autologon password
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultPassword"
    Value = $local_password
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