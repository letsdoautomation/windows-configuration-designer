## Software list
Download: [Microsoft Teams](https://learn.microsoft.com/en-us/microsoftteams/msi-deployment) <br />
Download: [Telegram](https://desktop.telegram.org/) <br />
Download: [WinRAR](https://www.win-rar.com/download.html?&L=0) <br />

Install WinRAR <br />
```powershell
msiexec.exe /i Teams_windows_x64.msi /quiet /qn /norestart
```

Disable "Privacy Experience" <br />
<img src="img/privacySettings.png" width=40% height=40%>
```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```

Run script to deploy WinRAR and Telegram
```powershell
powershell.exe -ExecutionPolicy Bypass -File run.ps1
```

## PSEXEC
[PSEXEC with Windows Configuration Designer example](https://learn.microsoft.com/en-us/windows/configuration/provisioning-packages/provisioning-script-to-install-app#powershell-example) <br />
[PSEXEC download](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec)
