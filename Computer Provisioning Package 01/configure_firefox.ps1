$firefox_settings = 
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 1
    Name  = "Locked"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 1
    Name  = "Search"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "Highlights"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "Pocket"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "Snippets"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "SponsoredPocket"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "SponsoredTopSites"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome"
    Value = 0
    Name  = "TopSites"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = 1
    Name  = "NoDefaultBookmarks"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = 1
    Name  = "DisablePocket"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = "" 
    Name  = "OverrideFirstRunPage"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = 1
    Name  = "DisableFirefoxAccounts"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = 1
    Name  = "DisableProfileImport"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"
    Value = "https://addons.mozilla.org/firefox/downloads/file/4216633/ublock_origin-1.55.0.xpi"
    Name  = ++$firefox_extension_count
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Mozilla\Firefox"
    Value = 1
    Name  = "DontCheckDefaultBrowser"
} | group Path

foreach($setting in $firefox_settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}