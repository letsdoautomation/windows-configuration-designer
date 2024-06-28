# Execute oobe scripts
. .\oobe-powersettings.ps1
. .\oobe-deploy-tmp.ps1 -ArchivePackageName "oobe-_tmp.exe" -Destination "C:\_tmp"
. .\oobe-chocolatey.ps1
. .\oobe-chrome-extensions.ps1

# Prepare provisioning folder
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Create local admin account
$local_user = @{
    Name                 = 'admin'
    NoPassword           = $true
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
[PSCustomObject]@{ # Use "Active Setup" to import desktop-icons.reg
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\DesktopIcons"
    Name  = "StubPath"
    Value = 'reg import "{0}\desktop-icons.reg"' -f $provisioning.FullName
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