$brave_settings = 
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\BraveSoftware\Brave"
    Value = 1 # 0 - Enable, 1 - Disable
    Name  = "BraveRewardsDisabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\BraveSoftware\Brave"
    Value = 1 # 0 - Enable, 1 - Disable
    Name  = "BraveVPNDisabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\BraveSoftware\Brave"
    Value = 1 # 0 - Enable, 1 - Disable
    Name  = "BraveWalletDisabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\BraveSoftware\Brave"
    Value = 1 # 0 - Enable, 1 - Disable
    Name  = "TorDisabled"
} | group Path

foreach($setting in $brave_settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}