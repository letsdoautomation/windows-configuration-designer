# Windows Configuration Designer: Configure single application KIOSK mode

<b>Documentation:</b>

* [AssignedAccess (Windows Configuration Designer reference)](https://learn.microsoft.com/en-us/windows/configuration/wcd/wcd-assignedaccess#assignedaccesssettings)
* [Create an Assigned Access configuration XML file](https://learn.microsoft.com/en-us/windows/configuration/assigned-access/configuration-file?pivots=windows-11)
* [Configure Microsoft Edge kiosk mode](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-configure-kiosk-mode)

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>

## Automated actions

* Actions performed in OOBE by provisioning package
  * Disable OOBE
  * Create admin account
  * Set admin password to never expires
  * Configure Kiosk
    * Launch edge on startup
    * Set startup page to C:\Kiosk\index.html
  * Deploy static web page to C:\Kiosk\

<b>Deploy static web page:</b>

```
cmd /c copy index.exe %TEMP% && cmd /c %TEMP%\index.exe -y -o"C:\Kiosk"
```

<b>Set never expires for admin passwotd:</b>

```
powershell.exe -Command Set-LocalUser -name admin -PasswordNeverExpires $true
```

## Related videos

<b>PowerShell:</b>

* [PowerShell playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
* [Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu](https://youtu.be/lpbrQIvKGI4)
