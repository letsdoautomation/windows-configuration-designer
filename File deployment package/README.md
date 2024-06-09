# Windows Configuration Designer: File deployment package

 <b>Objectives:</b>

 * Create bare minimum package to go from OOBE to users desktop and deploy files
    * Deploy files
    * Skip OOBE
    * Execute oobe-setup.ps1
        * Skip Privacy Experiance
        * Create local administrators account
        * Configure Power Settings

* Create self-extracting file executable with 7-Zip

### Part 1: Creating self-extracting executable

### Part 2: Creating provisioning package

<b>Execute oobe-setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

<b>Execute file deployment:</b>

```batch
cmd /c copy files.exe %TEMP% && cmd /c %TEMP%\files.exe -y -o"C:\Files"
```

## Realted videos

[Windows Tools: Self extracting  EXE archive with 7 zip](https://youtu.be/8Iaj9hbnnBA) <br />
[PowerShell: Get-LocalUser, New-LocalUser, Set-LocalUser, Disable-LocalUser and Enable, Remove](https://youtu.be/9PtT7FfPO3Q) <br />
[PowerShell: Windows 11 disable privacy experience for new users](https://youtu.be/YSVsOY2A7F8) <br />
[Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I) <br />
[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)