# Windows Configuration Designer: Creating viewer requested Windows automation package 06

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>

## Automated actions

* Actions performed in OOBE by provisioning package:
    * Skip OOBE
    * Execute oobe-setup.ps1
        * Create C:\ProgramData\provisioning
        * Copy files from provisioning package to C:\ProgramData\provisioning directory
        * Create s_service.user local administrator user
        * Disable privacy experience menu
        * Configure autologon for s_service.user
        * Configure RunOnce to execute desktop-provisioning.ps1
        * Active Setup

<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1 -local_username "s_service.user" -local_password "P@ssword50" -domain_username "s_service.user2" -domain_password "P@ssword51" -domain_name "ad.letsdoautomation.com"
```