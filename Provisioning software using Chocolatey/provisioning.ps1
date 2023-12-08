# Wait for network
$ProgressPreference_bk = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
do{
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if(!$ping){
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while(!$ping)
$ProgressPreference = $ProgressPreference_bk

##
# Chocolatey part
##
# Chocolatey software installation
$packages =
"adobereader",
"microsoft-teams.install",
"googlechrome",
"7zip.install",
"firefox",
"libreoffice-fresh",
"vlc",
"notepadplusplus.install"

$packages | %{
    choco install $_ -y --no-progress --ignore-checksums
}

# best place to add more actions

Write-Host "All Done!" -ForegroundColor Green
Read-Host