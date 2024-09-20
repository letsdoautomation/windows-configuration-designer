# Prepare provisioning folder
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

. .\oobe-software.ps1
. .\oobe-request.ps1 -ProvisioningFolder $provisioning

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Name -ne "start2.bin"} | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Create local admin account
$local_user = @{
    Name       = 'admin'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

$settings =
[PSCustomObject]@{ # Execute desktop-provisioning.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-update-provisioning.ps1 -First" -f $provisioning.FullName
},
[PSCustomObject]@{ # Skip privacy experiance
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