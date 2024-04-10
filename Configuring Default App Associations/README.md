# Windows Configuration Designer: Configuring Default App Associations

<b>Objectives:</b>

* Install applications:
    * Google Chrome
    * Adobe Reader
* Set Default Applications:
    * Google Chrome as default browser
    * Adobe Reader as default PDF reader
* Create admin user
* Skip OOBE
* Skip "Privacy experiance"

<b>Rules to folow:</b>

* Software needs to be installed before users <b>first</b> login
* Default Applications need to be set before users <b>first</b> login

<b>Download URL's:</b>

* [Google Chrome](https://chromeenterprise.google/browser/download/#windows-tab)
* [Adobe Reader](https://get.adobe.com/reader/enterprise/)

<b>Install Google Chrome:</b>

```powershell
msiexec.exe /i googlechromestandaloneenterprise64.msi /qn /norestart
```

<b>Install Adobe Reader:</b>

```powershell
cmd /c AcroRdrDC2400120643_en_US.exe /sAll /rs /msi EULA_ACCEPT=YES
```

<b>Export-DefaultAppAssociations:</b>

```powershell
dism /online /Export-DefaultAppAssociations:"C:\associations.xml"
```

<b>Execute associations.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File associations.ps1
```

<b>Create admin user and add it to administrators group:</b>

```powershell
cmd /c net user admin /add && net localgroup administrators admin /add
```

<b>Skip "Privacy experiance":</b>

<img src="img/privacySettings.png" width=40% height=40%>

```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

## Related videos

[Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)