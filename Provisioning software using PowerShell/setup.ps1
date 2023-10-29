$software_packages = "$($env:ProgramData)\software_packages"

ni $software_packages -ItemType Directory -Force | Out-Null

gci | ?{$_.name -ne "setup.ps1"} | %{
    cp $_.FullName "$($software_packages)\$($_.name)" -Force
}

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "Install_Software" -Value ("cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\install_software.ps1" -f $software_packages)