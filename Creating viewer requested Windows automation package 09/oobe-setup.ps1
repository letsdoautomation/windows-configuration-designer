# Create local admin account
$local_user = @{
    Name       = 'admin'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

$settings =
[PSCustomObject]@{ # Execute desktop-provisioning.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-provisioning.ps1" -f $provisioning.FullName
},
[PSCustomObject]@{ # Disable privacy experiance
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
} | group Path

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