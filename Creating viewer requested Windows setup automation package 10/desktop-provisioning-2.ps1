# Wait for network
do {
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if (!$ping) {
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 10
    }
} while (!$ping)

# Wait for winget to be installed
do {
    try {
        Start-Process "winget" -ea Stop
        break
    }
    catch [System.InvalidOperationException] {
        'Wainting for winget' | Out-Host
        sleep -s 30
    }
} while (1)

# Set time to display list of operating systems to 0
bcdedit /timeout 0

# Install winget software packages
$packages = 
'Google.Chrome',
'Zoom.Zoom',
'Apple.iTunes',
'Malwarebytes.Malwarebytes',
'CodecGuide.K-LiteCodecPack.Full',
'Microsoft.DotNet.Runtime.8',
'Microsoft.DotNet.Runtime.9',
'AdoptOpenJDK.OpenJDK.17.OpenJ9',
'7zip.7zip',
'Apache.OpenOffice',
'Piriform.CCleaner',
'Adobe.Acrobat.Reader.64-bit'

foreach ($package in $packages) {
    winget install -e --id $package --silent --accept-source-agreements
}

# Execute Ninite
$execute_ninite = @{
    FilePath    = "$($env:ProgramData)\provisioning\ninite.exe"
}
$ninite_process = Start-Process @execute_ninite

sleep -Seconds 300

Get-Process Ninite | Stop-Process


# Enable system restore
$enable_computer_restore = @{
    Drive = "C:\"
}
Enable-ComputerRestore @enable_computer_restore

# Configure system restore to 1% of disk space
vssadmin resize shadowstorage /for=C: /on=C: /maxsize=1%

# Create system restore point
$create_checkpoint = @{
    Description = "Restore point"
}
Checkpoint-Computer @create_checkpoint

Write-Host "Done" -BackgroundColor Green

Read-Host