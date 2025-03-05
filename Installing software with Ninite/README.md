# Windows Configuration Designer: Installing software with Ninite

<b>Notes:</b>

* Ninite software installation needs to be last step in the provisioning process

* Actions performed in OOBE by provisioning package
  * Skip OOBE 
  * Execute oobe-setup.ps1
    * Create admin account
    * Move files from provisioning package to C:\PrograData\Provisioning folder
    * Configure RunOnce to execute desktop-provisioning.ps1
    * Disable privacy experiance menu
* Actions performed in users desktop by desktop-provisioning.ps1
  * Wait for network connection
  * Install software using Ninite

<b>Downloads:</b>

* [Ninite](https://ninite.com/)

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