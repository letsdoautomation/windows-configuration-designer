$packages = 
"googlechrome",
"adobereader",
"office365business" -join " "

$chocolatey_msi_file = "chocolatey-2.3.0.0.msi"

$install_chocolatey = @{
    FilePath         = '{0}\system32\msiexec.exe' -f $env:SystemRoot
    ArgumentList     = '/i "{0}\{1}" /qn /norestart' -f (gl).path, $chocolatey_msi_file
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_chocolatey

# Install chocolatey packages
$install_software_packages = @{
    FilePath     = "C:\ProgramData\chocolatey\choco.exe"
    ArgumentList = "install {0} -y --no-progress --ignore-checksums" -f $packages
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}

Start-Process @install_software_packages