# Monitor flip
$monitor_configuration_registry_location = "SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"

$current_monitor_setup = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($monitor_configuration_registry_location, $true)

$settings = @()

$settings += foreach ($monitor in $current_monitor_setup.GetSubKeyNames()) {

    # 1 = Landscape
    # 2 = Portrait
    # 3 = Landscape (flipped)
    # 4 = Portrait (flipped)

    [PSCustomObject]@{
        Path  = "$($monitor_configuration_registry_location)\$($monitor)\00\00"
        Name  = "Rotation"
        Value = 2
    }
}

$current_monitor_setup.Dispose()

$settings += [PSCustomObject]@{ # Execute desktop-kiosk.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_kiosk_configuration"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-kiosk.ps1"
}

# Apply registry settings
foreach ($setting in ($settings | group Path)) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}

Restart-Computer