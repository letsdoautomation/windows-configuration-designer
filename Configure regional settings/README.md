# Windows Configuration Designer: Configure regional settings

<b>Objectives:</b>

* Create bare minimum package to go from OOBE to users desktop
    * Skip OOBE
    * Execute oobe-setup.ps1
        * Skip Privacy Experiance
        * Create local administrators account
        * Configure Power Settings
        * Execute oobe-regional.ps1 (Hungarian)
            * Configure time zone
            * Configure keyboard settings
            * Configure home location
            * Configure locale
            * Configure region
        * Configure RunOnce to execute desktop-provisioning.ps1
            * Change interface language to Hungarian

<b>Execute oobe-setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

### Related videos

<b>Regional powershell commands:</b>

[Get-Culture, Set-Culture](https://youtu.be/gS4BckaTKto) <br />
[Get-InstalledLanguage, Install-Language, Get and Set-SystemPreferredUILanguage](https://youtu.be/eN-56mOM5GQ) <br />
[Get-TimeZone, Set-TimeZone](https://youtu.be/fmoIfJwvH-I) <br />
[Get-WinHomeLocation, Set-WinHomeLocation](https://youtu.be/yWp_1L8YDoQ) <br />
[Get-WinSystemLocale, Set-WinSystemLocale](https://youtu.be/rCGlh3hp1fI) <br />
[Get-WinUserLanguageList, Set-WinUserLanguageList](https://youtu.be/Bhl-rLB8g28) <br />

<b>Other:</b>

[PowerShell: Get-LocalUser, New-LocalUser, Set-LocalUser, Disable-LocalUser and Enable, Remove](https://youtu.be/9PtT7FfPO3Q) <br />
[PowerShell: Windows 11 disable privacy experience for new users](https://youtu.be/YSVsOY2A7F8) <br />
[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
