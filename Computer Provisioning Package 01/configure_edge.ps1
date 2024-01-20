$edge_search_engines =
@{
    is_default = $true
    keyword = "google"
    name = "google.com"
    search_url = "https://www.google.com/search?q={searchTerms}"
},
@{
    keyword = "duck"
    name = "duckduckgo.com"
    search_url = "https://duckduckgo.com/?q={searchTerms}"
} | ConvertTo-Json -Compress

$edge_settings = 
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "PinBrowserEssentialsToolbarButton"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0 # 1 - Enable, 0 - Disable
    Name  = "ImportFavorites"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = $edge_search_engines
    Name  = "ManagedSearchEngines"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "SplitScreenEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 1
    Name  = "HideFirstRunExperience"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "EdgeShoppingAssistantEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "PersonalizationReportingEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "HubsSidebarEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0
    Name  = "EdgeCollectionsEnabled"
},
[PSCustomObject]@{ 
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 1 # Remove default sites
    Name  = "NewTabPageHideDefaultTopSites"
},
[PSCustomObject]@{ 
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 3 # Remove background
    Name  = "NewTabPageAllowedBackgroundTypes"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0 # Disable APP launcher
    Name  = "NewTabPageAppLauncherEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = 0 # Remove news and other stuff
    Name  = "NewTabPageContentEnabled"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
    Value = "odfafepnkmbhccpbejgmiehpchacaeak" # uBlock Origin
    Name  = ++$edge_extension_count
} | group Path

foreach($setting in $edge_settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}