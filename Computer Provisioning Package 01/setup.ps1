# create local administrator account
$local_user = @{
    Name                 = 'admin'
    NoPassword           = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

# prepare provisioning folder
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -ne "setup.ps1" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# configure windows registry to:
# * setup RunOnce to execute provisioning.ps1 script
# * disable privacy experience
$settings =
[PSCustomObject]@{
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\provisioning.ps1 -first" -f $provisioning.FullName
},
[PSCustomObject]@{
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

# Disable sleep, hibernate and monitor standby on AC
"powercfg /x -monitor-timeout-ac 0",
"powercfg /x -standby-timeout-ac 0",
"powercfg /x -hibernate-timeout-ac 0" | % {
    cmd /c $_
}