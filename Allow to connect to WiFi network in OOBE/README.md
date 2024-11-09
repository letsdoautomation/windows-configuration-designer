# Windows Configuration Designer: Allow to connect to WiFi network in OOBE

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>

<b>Notes:</b>

* Configuration for computers with Windows OEM pre-install
* Better option most likely would be to inject oobe configuration in Windows installation

## Automated actions

* Actions performed in OOBE by provisioning package:
  * Execute oobe-setup.ps1
    * Create C:\ProgramData\provisioning
    * Copy files from provisioning package to C:\ProgramData\provisioning directory
    * Disable first logon animation
    * Configure RunOnce to execute desktop-provisioning.ps1
  *  Execute oobe-configure.ps1
     * Execute sysprep with unattend.xml
        * Hide everything in oobe except for connect to network menu
        * Create admin user
        * Configure en-us regional settings
* Actions performed by desktop-provisioning.ps1 in provisioning users Desktop
  * Install Google Chrome

### Downloads

* [Google Chrome](https://chromeenterprise.google/download/)

<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

<b>oobe-configure.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-configure.ps1
```

## Related videos

<b>PowerShell:</b>

* [PowerShell playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
* [Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu](https://youtu.be/lpbrQIvKGI4)
