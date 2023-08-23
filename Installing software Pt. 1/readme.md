## Software list
Download: [Telegram](https://desktop.telegram.org/) <br />
```powershell
# Make sure that executable name is correct
cmd /c xcopy /-I tsetup-x64.4.9.2.exe %ALLUSERSPROFILE%\deployment_files\telegram\tsetup.exe && cmd /c reg add "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\Install Telegram" /v StubPath /t REG_SZ /d "%ALLUSERSPROFILE%\deployment_files\telegram\tsetup.exe /VERYSILENT /NORESTART"
```
Download: [Microsoft Teams](https://learn.microsoft.com/en-us/microsoftteams/msi-deployment) <br />
```powershell
msiexec.exe /i Teams_windows_x64.msi /quiet /qn /norestart
```
Download link: [WinRAR](https://www.win-rar.com/download.html?&L=0) <br />
```powershell
# Make sure that executable name is correct
cmd /c copy winrar-x64-623.exe %TEMP% && cmd /c %TEMP%\winrar-x64-623.exe /S
```
Disable "Privacy Experience" <br />
<img src="img/privacySettings.png" width=40% height=40%>
```powershell
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1
```