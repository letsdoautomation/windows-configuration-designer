# Windows Configuration Designer: Provisioning software using winget
<b>Objectives:</b>

* Install software using winget script:
    * Adobe.Acrobat.Reader.64-bit
    * Microsoft.Teams.Classic
    * Google.Chrome
    * 7zip.7zip
    * Mozilla.Firefox
    * Zoom.Zoom
    * Microsoft.VisualStudioCode
    * VideoLAN.VLC
* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"
* Disable sleep for monitor and computer

<b>Provisioning stages</b>

* <b>Windows Configuration Designer stage:</b>
    * Preparing for winget stage with setup.ps1 script:
        * Placing winget update files in C:\programdata\provisioning
        * Placing provisioning.ps1 in C:\programdata\provisioning
        * Preparing RunOnce in HKLM to execute software provisioning
    * Configuring autologon
        * Skipping OOBE
        * Skipping "Privacy Experience"
        * Creating admin user without password
        * Adding admin to Administrators group
    * Disabling sleep
* <b>Winget stage using provisioning.ps1 script:</b>
    * Updating winget
    * Waiting for network connection
    * Installing software

<b>Winget update files:</b>

* [Install winget on Windows Sandbox](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox) <br />

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
