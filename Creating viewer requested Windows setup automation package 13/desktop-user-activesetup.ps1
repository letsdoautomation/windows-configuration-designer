$settings = @()
[IO.DirectoryInfo]$provisioning = "$($env:ProgramData)\provisioning"

# Prevent OneDrive from installing
$prevent_onedrive_install = @{
    Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    Name = "OneDriveSetup"
}
Remove-ItemProperty @prevent_onedrive_install

# Registry configuration
$settings += 
[PSCustomObject]@{ # Execute desktop-user-runonce.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_user_runonce"
    Value = 'powershell.exe -Command "gc {0}\desktop-user-runonce.ps1 -Raw | iex"' -f $provisioning.FullName
}

foreach ($setting in ($settings | group Path)) {
    $registry = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($setting.Name, $true)
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