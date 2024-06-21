$software_packages =
'7zip.install',
'notepadplusplus.install',
'vlc' -join " "

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

$install_software_packages = @{
    FilePath         = "C:\ProgramData\chocolatey\choco.exe"
    ArgumentList     = "install {0} -y --no-progress --ignore-checksums" -f $software_packages
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_software_packages


Write-Host "All Done!" -ForegroundColor Green
Read-Host