# configure time zone
Get-TimeZone -ListAvailable | ?{$_.DisplayName -like "*Budapest*"} | Set-TimeZone

# configure regional/locale/keyboard settings
# Hungarian
$region = "hu-HU"

Set-Culture $region
Set-WinSystemLocale $region
Set-WinUserLanguageList $region, "en-us" -force -wa silentlycontinue
Set-WinHomeLocation 109

# copy regional settings to new user accounts and welcome screen
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True