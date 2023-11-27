# Windows Configuration Designer: Configuring WiFi connection
<b>Objectives:</b>

* Configure Wi-Fi settings
* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"

<b>Disable "Privacy Experience"</b>

<img src="img/privacySettings.png" width=40% height=40%>

```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

<b>Create user admin and add to Administrators group </b>
```powershell
cmd /c net user admin /add && net localgroup administrators admin /add
```

# Related videos

<b>Windows Configuration Designer</b>

[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU) <br />