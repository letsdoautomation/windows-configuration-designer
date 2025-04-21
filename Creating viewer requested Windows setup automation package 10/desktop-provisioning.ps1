
# User settings 
$settings = 
[PSCustomObject]@{ # Hide recently added apps
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "Start_TrackDocs"
},
[PSCustomObject]@{ # Hide recently added apps
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Start"
    Value = 0
    Name  = "ShowRecentList"
},
[PSCustomObject]@{ # Hide recently added apps
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "Start_IrisRecommendations"
},
[PSCustomObject]@{ # Move taskbar to left
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "TaskbarAl"
},
[PSCustomObject]@{ # Change search bar to search icon
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Value = 1
    Name  = "SearchboxTaskbarMode"
},
[PSCustomObject]@{ # Remove task view button
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = 1
    Name  = "HideTaskViewButton"
},
[PSCustomObject]@{ # Enable This PC desktop icon
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name  = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
},
[PSCustomObject]@{ # Enable Users files desktop icon
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name  = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
},
[PSCustomObject]@{ # Enable Recycle bin desktop icon
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name  = "{645FF040-5081-101B-9F08-00AA002F954E}"
},
[PSCustomObject]@{ # Start menu more pins
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 1
    Name  = "Start_Layout"
},
[PSCustomObject]@{ # Set Windows dark theme
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Value = 0
    Name  = "SystemUsesLightTheme"
},
[PSCustomObject]@{ # Set application ligth theme
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Value = 1
    Name  = "AppsUseLightTheme"
},
[PSCustomObject]@{ # Disable transparency
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Value = 0
    Name  = "EnableTransparency"
},
[PSCustomObject]@{ # Show accent color in start and taskbar
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Value = 1
    Name  = "ColorPrevalence"
},
[PSCustomObject]@{ # Show accent color in start and taskbar
    Path  = "SOFTWARE\Microsoft\Windows\DWM"
    Value = 1
    Name  = "ColorPrevalence"
},
[PSCustomObject]@{ # Disable notifications
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"
    Value = 0
    Name  = "ToastEnabled"
},
[PSCustomObject]@{ # Enable custom performance settings
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    Value = 3
    Name  = "VisualFXSetting"
},
[PSCustomObject]@{ 
    # Enable animate controls and elements inside windows
    # Disable Fade or slide menus into view
    # Disable Fade or slide ToolTips into view
    # Disable Fade out menu items after clicking
    # Disable Show shadows under mouse pointer
    # Disable Show shadows under windows
    # Disable Slide open combo boxes
    # Disable Smooth-scroll list boxes
    Path  = "Control Panel\Desktop"
    Value = [byte[]](0x90,0x12,0x03,0x80,0x12,0x00,0x00,0x00)
    Name  = "UserPreferencesMask"
},
[PSCustomObject]@{ # Enable Smooth edges of screen fonts
    Path  = "Control Panel\Desktop"
    Value = "2"
    Name  = "FontSmoothing"
},
[PSCustomObject]@{ # Disable Show window contents while dragging
    Path  = "Control Panel\Desktop"
    Value = "0"
    Name  = "DragFullWindows"
},
[PSCustomObject]@{ # Disable Animate windows when minimizing and maximizing
    Path  = "Control Panel\Desktop\WindowMetrics"
    Value = "0"
    Name  = "MinAnimate"
},
[PSCustomObject]@{ # Enable Show thumbnails instead of icons
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "IconsOnly"
},
[PSCustomObject]@{ # Enable Use drop shadows for icon labels on the desktop
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 1
    Name  = "ListviewShadow"
},
[PSCustomObject]@{ # Disable Animations in the taskbar
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "TaskbarAnimations"
},
[PSCustomObject]@{ # Disable Show translucent selection rectangle
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "ListviewAlphaSelect"
},
[PSCustomObject]@{ # Disable Peek
    Path  = "SOFTWARE\Microsoft\Windows\DWM"
    Value = 0
    Name  = "EnableAeroPeek"
},
[PSCustomObject]@{ # Disable let websites provide locally relevant content by accessing my language list
    Path  = "Control Panel\International\User Profile"
    Value = 1
    Name  = "HttpAcceptLanguageOptOut"
},
[PSCustomObject]@{ # Disable let Windows improve Start and search results by tracking app launches
    Path  = "Software\Policies\Microsoft\Windows\EdgeUI"
    Value = 1
    Name  = "DisableMFUTracking"
},
[PSCustomObject]@{ # Disable show me suggested content in settings app
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Value = 0
    Name  = "SubscribedContent-338393Enabled"
},
[PSCustomObject]@{ # Disable show me suggested content in settings app
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Value = 0
    Name  = "SubscribedContent-353694Enabled"
},
[PSCustomObject]@{ # Disable show me suggested content in settings app
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Value = 0
    Name  = "SubscribedContent-353696Enabled"
},
[PSCustomObject]@{ # Disable show me notifications in settings app
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications"
    Value = 0
    Name  = "EnableAccountNotifications"
},
[PSCustomObject]@{ # Disable inking & typing personalization
    Path  = "SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    Value = 0
    Name  = "HarvestContacts"
},
[PSCustomObject]@{ # Disable inking & typing personalization
    Path  = "SOFTWARE\Microsoft\Microsoft\InputPersonalization"
    Value = 1
    Name  = "RestrictImplicitInkCollection"
},
[PSCustomObject]@{ # Disable inking & typing personalization
    Path  = "SOFTWARE\Microsoft\Microsoft\InputPersonalization"
    Value = 1
    Name  = "RestrictImplicitTextCollection"
},
[PSCustomObject]@{ # Disable inking & typing personalization
    Path  = "SOFTWARE\Microsoft\Personalization\Settings"
    Value = 0
    Name  = "AcceptedPrivacyPolicy"
},
[PSCustomObject]@{ # Set never feedback frequency
    Path  = "SOFTWARE\Microsoft\Siuf\Rules"
    Value = 0
    Name  = "NumberOfSIUFInPeriod"
},
[PSCustomObject]@{ # Disable tailored experiences
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
    Value = 0
    Name  = "TailoredExperiencesWithDiagnosticDataEnabled"
},
[PSCustomObject]@{ # Disable history from device
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
    Value = 0
    Name  = "IsDeviceSearchHistoryEnabled"
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

# computer settings
$settings = 
[PSCustomObject]@{ # Disable taskbar widgets
    Path  = "SOFTWARE\Policies\Microsoft\Dsh"
    Value = 0
    Name  = "AllowNewsAndInterests"
},
[PSCustomObject]@{ # Hide recently added apps
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = 1
    Name  = "HideRecentlyAddedApps"
},
[PSCustomObject]@{ # Start pin documents
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderDocuments"
},
[PSCustomObject]@{ # Start pin downloads
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderDocuments_ProviderSet"
},
[PSCustomObject]@{ # Start pin downloads
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderDownloads"
},
[PSCustomObject]@{ # Start pin downloads
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderDownloads_ProviderSet"
},
[PSCustomObject]@{ # Start pin file explorer
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderFileExplorer"
},
[PSCustomObject]@{ # Start pin file explorer
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderFileExplorer_ProviderSet"
},
[PSCustomObject]@{ # Start pin music folder
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderMusic"
},
[PSCustomObject]@{ # Start pin music folder
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderMusic_ProviderSet"
},
[PSCustomObject]@{ # Start pin personal folder
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderPersonalFolder"
},
[PSCustomObject]@{ # Start pin personal folder
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderPersonalFolder_ProviderSet"
},
[PSCustomObject]@{ # Start pin pictures
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderPictures"
},
[PSCustomObject]@{ # Start pin pictures
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderPictures_ProviderSet"
},
[PSCustomObject]@{ # Start pin settings
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderSettings"
},
[PSCustomObject]@{ # Start pin settings
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderSettings_ProviderSet"
},
[PSCustomObject]@{ # Start pin videos
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderVideos"
},
[PSCustomObject]@{ # Start pin videos
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderVideos_ProviderSet"
},
[PSCustomObject]@{ # Disable disable online speech recognition
    Path  = "SOFTWARE\Policies\Microsoft\InputPersonalization"
    Value = 0
    Name  = "AllowInputPersonalization"
},
[PSCustomObject]@{ # Disable disable online speech recognition
    Path  = "SOFTWARE\Policies\Microsoft\InputPersonalization"
    Value = 0
    Name  = "AllowInputPersonalization"
},
[PSCustomObject]@{ # Disable Diagnostic & feedback
    Path  = "SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    Value = 0
    Name  = "AllowTelemetry"
},
[PSCustomObject]@{ # Disable Activity history
    Path  = "SOFTWARE\Policies\Microsoft\Windows\System"
    Value = 0
    Name  = "PublishUserActivities"
},
[PSCustomObject]@{ # Disable Cloud content search
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Value = 0
    Name  = "AllowCloudSearch"
},
[PSCustomObject]@{ # Disable search highlights
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Value = 0
    Name  = "EnableDynamicContentInWSB"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = 1
    Name  = "EnrollmentState"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = 0
    Name  = "EnrollmentType"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = 0
    Name  = "IsFederated"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = 14089087
    Name  = "Flags"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = "0x000000000000000000000000000000000000000000000000000000000000000000000000"
    Name  = "AcctUId"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = 0
    Name  = "RoamingCount"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = "MY;User;0000000000000000000000000000000000000000"
    Name  = "SslClientCertReference"
},
[PSCustomObject]@{ # Fake MDM https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/
    Path  = "SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    Value = "1.2"
    Name  = "ProtoVer"
},
[PSCustomObject]@{ # Set new page
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = "https://google.com"
    Name  = "NewTabPageLocation" 
},
[PSCustomObject]@{ # Set homepage
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = "https://google.com"
    Name  = "HomepageLocation" 
},
[PSCustomObject]@{ # Set homepage same as new page
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 1 # 1 - Enable, 2 - Disable
    Name  = "HomepageIsNewTabPage" 
},
[PSCustomObject]@{ # Show home button
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 1 # 1 - Enable, 2 - Disable
    Name  = "ShowHomeButton"
},
[PSCustomObject]@{ # Enable bookmarks
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 1 # 1 - Enable, 0 - Disable
    Name  = "BookmarkBarEnabled"
},
[PSCustomObject]@{ # Disable Google Chrome background mode
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0 # 1 - Enable, 0 - Disable
    Name  = "BackgroundModeEnabled"
},
[PSCustomObject]@{ # Disable Google Chrome first run pop-ups
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PromotionsEnabled"
},
[PSCustomObject]@{ # Disable Google Chrome first run pop-ups
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxPromptEnabled" 
},
[PSCustomObject]@{ # Disable Google Chrome first run pop-ups
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxAdMeasurementEnabled"
},
[PSCustomObject]@{ # Disable Google Chrome first run pop-ups
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxAdTopicsEnabled"
},
[PSCustomObject]@{ # Disable Google Chrome first run pop-ups
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = 0
    Name  = "PrivacySandboxSiteEnabledAdsEnabled"
},
[PSCustomObject]@{ # Execute desktop-provisioning-2.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning_2"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\desktop-provisioning-2.ps1"
}

<#
[PSCustomObject]@{ # start pin network
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderNetwork"
},
[PSCustomObject]@{ # start pin network
    Path  = "SOFTWARE\Microsoft\PolicyManager\current\device\Start"
    Value = 1
    Name  = "AllowPinnedFolderNetwork_ProviderSet"
}
#>

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

# Configure power settings
"powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
"powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3",
"powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3",
"powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0",
"powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0",
"powercfg /S SCHEME_CURRENT",
"powercfg /x -monitor-timeout-ac 0",
"powercfg /x -standby-timeout-ac 0",
"powercfg /x -monitor-timeout-dc 0",
"powercfg /x -standby-timeout-dc 0",
"powercfg -h off" | % {
    cmd /c $_
}

Restart-Computer