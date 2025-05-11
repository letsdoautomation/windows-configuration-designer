# Windows Configuration Designer: Creating viewer requested Windows setup automation package 10

<b>Request:</b>

<img src="img/request.png" width=50% height=50%>

* Actions performed in OOBE by provisioning package
  * Disable OOBE
  * Execute oobe-setup.ps1
    * Create "admin" account
    * Create C:\PrograData\provisioning folder on the computer
    * Move files from provisioning package to C:\PrograData\provisioning folder
    * Disable "Privacy experience" menu
    * Configure RunOnce to execute desktop-provisioning.ps1
* Actions performed by desktop-provisioning.ps1 in users Desktop
  * Install all '.msixbundle', '.appx' files in C:\PrograData\provisioning folder

<b>Downloads:</b>

[Download the Azure VPN Client](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-entra-vpn-client-windows?wt.mc_id=searchAPI_azureportal_inproduct_rmskilling&sessionId=33365bfbd5e9445897288f0caa60b738#download)

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