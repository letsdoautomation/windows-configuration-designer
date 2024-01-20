$chrome_settings = 
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxPromptEnabled" # notification
},
[PSCustomObject]@{ 
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxAdMeasurementEnabled"
},
[PSCustomObject]@{ 
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxAdTopicsEnabled"
},
[PSCustomObject]@{ 
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxSiteEnabledAdsEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 2
    Name  = "DefaultNotificationsSetting"
},
[PSCustomObject]@{
    Path  = "Software\Policies\Google\Chrome\ExtensionInstallForcelist"
    Value = "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    Name  = ++$chrome_extension_count
} | group Path

foreach($setting in $chrome_settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}