# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

$registry_settings =
[PSCustomObject]@{ # Execute desktop-provisioning.ps1 using RunOnce
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_desktop_provisioning"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-provisioning.ps1 -provisioning $($provisioning)"
},
[PSCustomObject]@{ # Disable first logon animation
    Path  = "Software\Microsoft\Windows\CurrentVersion\Policies\System"
    Name  = "EnableFirstLogonAnimation"
    Value = 0
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