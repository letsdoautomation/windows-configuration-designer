param(
    [System.IO.DirectoryInfo]$ProvisioningFolder
)

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

$packages =
[PSCustomObject]@{
    Name         = "vmware-tools"
    Exe          = "vmware-setup.exe"
    SilentSwitch = "/s /v/qn REBOOT=ReallySuppress EULAS_AGREED=1"
},
[PSCustomObject]@{
    Name         = "Wallpapers"
    Exe          = "Wallpapers.exe"
    SilentSwitch = '-y -o"{0}"' -f "$($ProvisioningFolder.FullName)\Wallpapers"
},
[PSCustomObject]@{
    Name         = "Office 365"
    Exe          = "setup.exe"
    SilentSwitch = "/configure $($ProvisioningFolder.FullName)\config.xml"
},
[PSCustomObject]@{
    Name         = "7-Zip"
    Exe          = "7z2409-x64.exe"
    SilentSwitch = "/S"
},
[PSCustomObject]@{
    Name         = "Notepad++"
    Exe          = "npp.8.7.7.Installer.x64.exe"
    SilentSwitch = "/S"
},
[PSCustomObject]@{
    Name         = "Zoom"
    Exe          = "ZoomInstallerFull.msi"
    SilentSwitch = "/qn /norestart ALLUSERS=1"
},
[PSCustomObject]@{
    Name         = "Adobe Reader"
    Exe          = "AcroRdrDC2400520414_en_US.exe"
    SilentSwitch = "/sAll /rs /msi EULA_ACCEPT=YES"
},
[PSCustomObject]@{
    Name         = "Avast"
    Exe          = "avast_free_antivirus_setup_online.exe"
    SilentSwitch = "/silent"
}

foreach ($package in $packages) {
    Write-Host "Executing $($package.Name) installation."
    if ($package.exe -Like "*.msi") {
        $execute = @{
            FilePath     = "msiexec"
            ArgumentList = "/i $($ProvisioningFolder.FullName)\$($package.exe) $($package.SilentSwitch)"
            NoNewWindow  = $true
            PassThru     = $true
            Wait         = $true
        }
    }
    else {
        $execute = @{
            FilePath     = "$($ProvisioningFolder.FullName)\$($package.exe)"
            ArgumentList = $package.SilentSwitch
            NoNewWindow  = $true
            PassThru     = $true
            Wait         = $true
        }
    }
    $result = Start-Process @execute
    Write-Host "    ExitCode: $($result.ExitCode)"
}

Read-Host