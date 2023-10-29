# Windows Configuration Designer
<b>Objectives:</b>

* Install software using powershell(to avoid 20min limit):
    * VLC
    * Adobe Acrobat Reader DC
    * 7-Zip
    * Google Chrome
    * Zoom
    * Firefox
    * Telegram
    * Brave
* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"
* Disable UAC(viewer request, I dont recommend doing it and you can skip this step)

<b>Documentation:</b>

* [Start-Process](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.3)

<b>Machine wide installation software list:</b>

* [VLC](https://www.videolan.org/)
    * <b>silent switch: </b>/S
* [Adobe Acrobat Reader DC](https://get.adobe.com/reader/enterprise/)
    * <b>silent switch: </b>/sAll /rs /msi EULA_ACCEPT=YES
* [7-Zip](https://7-zip.org/download.html)
    * <b>silent switch: </b>/S
* [Google Chrome](https://chromeenterprise.google/browser/download/#windows-tab)
    * <b>silent switch: </b>/qn /norestart
* [Zoom](https://support.zoom.us/hc/en-us/articles/207373866-Zoom-Installers)
    * <b>silent switch: </b>/qn /norestart
* [Firefox](https://www.mozilla.org/en-US/firefox/all/#product-desktop-release)
    * <b>silent switch: </b>/S

<b>User wide installation software list:</b>

* [Telegram](https://desktop.telegram.org/)
    * <b>silent switch: </b>/VERYSILENT /NORESTART
* [Brave](https://github.com/brave/brave-browser)
    * <b>silent switch: </b>N/A

<b>Silent switches</b>

* [letsdoautomation](https://github.com/letsdoautomation/silent-software-installations/tree/main)
* [community.chocolatey.org](https://community.chocolatey.org/packages)

<b>Execute setup.ps1</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File setup.ps1
```

<b>ActiveSetup example</b>

```powershell
ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\InstallSpotify" | New-ItemProperty -Name "StubPath" -Value 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v InstallSpotify /t REG_SZ /d "C:\SpotifyFullSetup.exe /Silent"'
```

<b>Disable "Privacy Experience"</b>

<img src="img/privacySettings.png" width=40% height=40%>

```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

<b>Disable UAC</b>

```powershell 
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```

<b>Create user admin and add to Administrators group </b>
```powershell
cmd /c net user admin /add && net localgroup administrators admin /add
```

# Related videos
<b>Windows registry</b>

[Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw) <br />
[Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo) <br />