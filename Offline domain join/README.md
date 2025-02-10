# Windows Configuration Designer: Offline domain join

<b>Documentation:</b>

[djoin](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/ff793312(v=ws.11))

<b>Notes:</b>

* Offline domain can be performed without connection to AD but connections is still required for first logon
  * Can be used with VPN before logon 

<b>Package actions:</b>

* Skip OOBE
* Execute oobe-setup.ps1
  * Disable privacy experience
* Execute oobe-offline-domain-join.ps1
  * Perform offline domain join
  * Restart

<b>Create multiple offline domain join files:</b>

```powershell
$computers =
"NB01",
"NB02",
"NB03",
"NB04",
"NB05",
"NB06",
"NB07",
"NB08",
"NB10"

foreach($computer in $computers){
    djoin /provision /domain "ad.letsdoautomation.com" /machine $computer /machineou "OU=NewComputers,DC=ad,DC=letsdoautomation,DC=com" /savefile "C:\Users\$($env:USERNAME)\Desktop\djoin\$($computer).txt"
}
```

<b>oobe-offline-domain-join.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-offline-domain-join.ps1 -usb_name "USB-256"
```

<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

## Related videos

<b>Windows Server:</b>

* [Offline domain join](https://youtu.be/3-L9Ak_kmlA)

<b>PowerShell:</b>

* [PowerShell playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
* [Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu](https://youtu.be/lpbrQIvKGI4)
