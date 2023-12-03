$provisioning = "$($env:ProgramData)\provisioning"

ni $provisioning -ItemType Directory -Force | Out-Null

gci -File | ?{$_.name -ne "setup.ps1"} | %{
    cp $_.FullName "$($provisioning)\$($_.name)" -Force
}

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "execute_provisioning" -Value ("cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\provisioning.ps1" -f $provisioning)