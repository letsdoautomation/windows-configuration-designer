$software_packages =
'adobereader',
'googlechrome' -join " "

$install_chocolatey = @{
    FilePath         = '{0}\system32\msiexec.exe' -f $env:SystemRoot
    ArgumentList     = '/i "{0}\chocolatey-2.3.0.0.msi" /qn /norestart' -f (gl).path
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_chocolatey

$install_software_packages = @{
    FilePath         = "C:\ProgramData\chocolatey\choco.exe"
    ArgumentList     = "install {0} -y --no-progress --ignore-checksums" -f $software_packages
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_software_packages

