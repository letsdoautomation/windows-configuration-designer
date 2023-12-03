# Wait for network
do{
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if(!$ping){
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while(!$ping)

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
    choco install $_ -y --no-progress
}

Write-Host "All Done!" -ForegroundColor Green
Read-Host