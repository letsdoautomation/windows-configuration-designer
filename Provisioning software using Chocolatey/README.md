# Windows Configuration Designer: Provisioning software using Chocolatey
<b>Objectives:</b>

* Install software using Chocolatey script:
    * adobereader
    * microsoft-teams.install
    * googlechrome
    * 7zip.install
    * firefox
    * libreoffice-fresh
    * vlc
    * notepadplusplus.install
* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"
* Configure Wi-Fi autoconnect
* Disable sleep for monitor and computer

<b>Provisioning stages</b>

* <b>Windows Configuration Designer stage:</b>
    * Installing Chocolatey
    * Configuring Wi-Fi autoconnect
    * Configuring autologon
        * Skipping OOBE
        * Skipping "Privacy Experience"
        * Creating admin user without password
        * Adding admin to Administrators group
    * Disabling sleep
* <b>Winget stage using provisioning.ps1 script:</b>
    * Waiting for network connection
    * Installing software

<b>Chocolatey installtion file:</b>

* [Chocolatey](https://github.com/chocolatey/choco) <br /><br />

```powershell
# Make sure that executable name is correct
msiexec.exe /i chocolatey-2.2.2.0.msi /quiet /qn /norestart
```

<b>Execute setup.ps1</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File setup.ps1
```

<b>Disable "Privacy Experience"</b>

<img src="img/privacySettings.png" width=40% height=40%>

```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

<b>Create user admin and add to Administrators group </b>
```powershell
cmd /c net user admin /add && net localgroup administrators admin /add
```

<b>Disable sleep for monitor and computer</b>
```powershell
cmd /c powercfg /x -monitor-timeout-ac 0 && powercfg /x -standby-timeout-ac 0
```

# Related videos
<b>Windows registry</b>

[Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw) <br />
[Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo) <br />

<b>Windows Configuration Designer</b>

[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU) <br />
[Windows Configuration Designer: Configuring WiFi connection](https://youtu.be/S2ysvv4KvRY) <br />