# Windows Configuration Designer: Creating viewer requested Windows automation package 09

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>

## Automated provisioning package actions

* Actions performed in OOBE by provisioning package
  * Disable OOBE
  * Set computer name to %SERIAL%
  * Execute oobe-setup.ps1
    * Create admin account
    * Create C:\PrograData\Provisioning folder on the computer
    * Move files from provisioning package to C:\PrograData\Provisioning folder
    * Configure RunOnce to execute desktop-provisioning.ps1
* Actions performed by desktop-provisioning.ps1 in users Desktop
  * Change screen orientation from landscape to portrait
  * Configure RunOnce to execute desktop-kiosk.ps1
  * Restart computer
* Actions performed by desktop-kiosk.ps1 in users Desktop
  * Execute kiosk-configuration.ps1 with PsExec

<b>Downloads:</b>

* [PsTools](https://learn.microsoft.com/en-us/sysinternals/downloads/pstools)

<b>Computer name pattern:</b>

```batch
%SERIAL%
```

<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

## Related videos

<b>PowerShell:</b>

* [PowerShell playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
* [Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu](https://youtu.be/lpbrQIvKGI4)
