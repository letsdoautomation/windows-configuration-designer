# Windows Configuration Designer: Deploy Office 2016 VL

<b>Downloads:</b>

 * [7-zip download page](https://www.7-zip.org/download.html) <br />
 * [Office Customization Tool (OCT) 2016 Help: Overview](https://learn.microsoft.com/en-us/deployoffice/oct/oct-2016-help-overview)<br />
* [Setup properties reference for Office 2013](https://learn.microsoft.com/en-us/previous-versions/office/office-2013-resource-kit/cc179018(v=office.15))

 <b>Objectives:</b>

 * Create bare minimum package to go from OOBE to users desktop and Install Office 2016 VL
    * Install Office 2016 VL
    * Skip OOBE
    * Execute oobe-setup.ps1
        * Skip Privacy Experiance
        * Create local administrators account
        * Configure Power Settings

* Create single executable to perform silent Office 2016 VL installation
    1. Create MSP configuration file to perform silent installation
    2. Package all installation files into single executable

### Part 1: Creating MSP configuration file

<b>Open Microsoft Office Customization Tool:</b>

```batch
setup.exe /admin
```

<b>Configure properties:</b>

* Name: SETUP_REBOOT
    * Value: Never
* Name: HIDEUPDATEUI
    * Value: True

### Part 2: Packaging Office 2016 VL installation files into single executable

<b>Create self extracting installation executable:</b>

```batch
copy /b 7zS.sfx + config.txt + office.7z Office.exe
```

### Part 3: Creating provisioning package

<b>Execute oobe-setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

<b>Execute Office 2016 VL installtion:</b>

```batch
cmd /c copy Office.exe %TEMP% && cmd /c %TEMP%\Office.exe
```


## Realted videos

[Silent software installation: Microsoft Office 2016 VL](https://youtu.be/a2k2bTDR_KE) <br />
[Windows Tools: Self extracting  EXE archive with 7 zip](https://youtu.be/8Iaj9hbnnBA) <br />
[PowerShell: Get-LocalUser, New-LocalUser, Set-LocalUser, Disable-LocalUser and Enable, Remove](https://youtu.be/9PtT7FfPO3Q) <br />
[PowerShell: Windows 11 disable privacy experience for new users](https://youtu.be/YSVsOY2A7F8) <br />
[Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I) <br />
[Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)

