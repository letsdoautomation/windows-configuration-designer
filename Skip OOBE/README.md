# Windows Configuration Designer: Skip OOBE

<b>Objectives:</b>

* Create bare minimum package to go from OOBE to users desktop
    * Skip OOBE
    * Skip Privacy Experiance
    * Create local administrators account
    * (OPTIONAL) Configure Power Settings

# Execute setup.ps1

```powershell
powershell.exe -ExecutionPolicy Bypass -File setup.ps1
```

### Related videos

[PowerShell: Get-LocalUser, New-LocalUser, Set-LocalUser, Disable-LocalUser and Enable, Remove](https://youtu.be/9PtT7FfPO3Q) <br />
[PowerShell: Windows 11 disable privacy experience for new users](https://youtu.be/YSVsOY2A7F8) <br />
[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)