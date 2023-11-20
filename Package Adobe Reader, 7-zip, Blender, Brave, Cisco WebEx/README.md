# Windows Configuration Designer
<b>Objectives:</b>

* Package software:
    * 7-Zip
    * Adobe Acrobat Reader DC
    * Blender
    * Brave
    * Cisco WebEx

* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"

## Packaging software

<b>Machine wide:</b><br />

* [7-Zip](https://7-zip.org/download.html)
    * msiexec.exe /i "7z2301-x64.msi" /quiet /qn /norestart
* [Adobe Acrobat Reader DC](https://get.adobe.com/reader/enterprise/)
    * cmd /c AcroRdrDC2300620380_en_US.exe /sAll /rs /msi EULA_ACCEPT=YES
* [Blender](https://www.blender.org/)
    * cmd /c blender-4.0.1-windows-x64.msi /quiet /norestart ALLUSERS=1
* [Cisco WebEx](https://www.webex.com/downloads.html)
    * cmd /c Webex_en.msi /quiet /norestart ALLUSERS=1

<b>User wide:</b><br />

* [Brave](https://github.com/brave/brave-browser)

## Create user admin and add to Administrators group
```powershell
cmd /c net user admin /add && net localgroup administrators admin /add
```

## Disable "Privacy Experience" <br />
<img src="img/privacySettings.png" width=40% height=40%>

```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

# Related videos
<b>Windows registry</b>

[Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw) <br />
[Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo) <br />

<b>Windows Configuration Designer</b>

[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)