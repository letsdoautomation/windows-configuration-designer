# Windows Configuration Designer: Configure single application KIOSK mode

<b>Documentation:</b>

* [AssignedAccess (Windows Configuration Designer reference)](https://learn.microsoft.com/en-us/windows/configuration/wcd/wcd-assignedaccess#assignedaccesssettings)
* [Create an Assigned Access configuration XML file](https://learn.microsoft.com/en-us/windows/configuration/assigned-access/configuration-file?pivots=windows-11)
* [Configure Microsoft Edge kiosk mode](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-configure-kiosk-mode)

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>

```
cmd /c copy index.exe %TEMP% && cmd /c %TEMP%\index.exe -y -o"C:\Kiosk"
```

```
powershell.exe -Command Set-LocalUser -name admin -PasswordNeverExpires $true
```


<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```