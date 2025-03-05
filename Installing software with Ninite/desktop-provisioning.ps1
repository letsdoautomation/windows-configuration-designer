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
    Name = "Ninite"
    Exe  = "ninite.exe"
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
            FilePath    = "$($ProvisioningFolder.FullName)\$($package.exe)"
            NoNewWindow = $true
            PassThru    = $true
            Wait        = $true
        }
        if (![string]::IsNullOrEmpty($package.SilentSwitch)) {
            $execute.ArgumentList = $package.SilentSwitch
        }
    }
    $result = Start-Process @execute
    Write-Host "    ExitCode: $($result.ExitCode)"
}

Read-Host