# wait for network
$ProgressPreference_bk = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
do {
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if (!$ping) {
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while (!$ping)
$ProgressPreference = $ProgressPreference_bk


# configure UI language
$language = "hu-HU"

$current_preferred_ui_lanague = Get-SystemPreferredUILanguage

if($language -ne $current_preferred_ui_lanague){
    $language_installed = Get-InstalledLanguage $language
    if(!$language_installed){
            $install_language = @{
            Language       = $language
        }
        Install-Language @install_language
    }
    Set-SystemPreferredUILanguage $language
}

Write-Host "All Done!" -ForegroundColor Green
Read-Host