# Windows Configuration Designer: Creating viewer requested Windows automation package 05

<b>Request:</b>

<img src="img/request.png" width=100% height=100%>
<img src="img/request2.png" width=100% height=100%>

## Package execution order

* <b>STAGE 1</b> Actions performed in OOBE:
    * Create admin1, admin2 users
    * Configure wireless network settings
    * Set computername to Xiente-%RAND:8%
    * Execute oobe-setup.ps1
        * Create local provisioning user
        * Create provisioning folder in C:\ProgramData\
        * Move files from provisioning package to C:\ProgramData\provisioning
        * Install chocolatey
        * Create desktop-user-registry.reg (Contains majority taskbar settings)
        * Configure autologon for provisioning user
        * Disable sleep and set close lid action to do nothing
        * Skip "Privacy Experience"
        * Disable widgets
        * <b>(If Windows 10)</b> Configure RunOnce to execute desktop-upgrade.ps1
        * <b>(If Windows 10)</b> Create autologon.bat
        * <b>(If not Windows 10)</b> Configure RunOnce to execute desktop-provisioning.ps1
* <b>STAGE 2</b> Actions performed in bplocal users desktop:
    * <b>(If Windows 10)</b> Execute desktop-upgrade.ps1
        * Wait for internet connection
        * Check if there is no compatibility issues
            * <b>If no issues found:</b>
                * Run Windows upgrade
                * Configure setup.exe to execute autologon.bat
                * Configure autologon once again
                * Configure RunOnce to execute desktop-provisioning.ps1
            * <b>If issues found:</b>
                * Execute desktop-provisioning.ps1
    * Execute desktop-provisioning.ps1
        * Wait for internet connection
        * Install PSWindowsUpdate
        * Use PSWindowsUpdate to install windows updates
        * <b>If</b> restart is required
            * Restart computer
            * Configure RunOnce to execute desktop-provisioning.ps1 to execute once again
        * <b>Else</b>
            * Remove Windows store apps
            * Remove Gallery and Home from file explorer
            * Configure timezone
            * Configure default program associations
                * Google Chrome as default browser
                * Adobe Reader as default PDF reader
                * Outlook as default mail client
            * <b>(If Windows 11)</b> Configure keyboard settings
            * <b>(If Windows 11)</b> Prevent Outlook (new) and Dev Home from installing
            * <b>(If Windows 11)</b> Deploy start menu layout
            * <b>(If Windows 11)</b> Configure ActiveSetup to remove Outlook (new) using RunOnce
            * Prevent OneDrive personal from installing
            * Configure taskbar
                * Pin Google Chrome
                * Pin Word
                * Pin Excel
                * Pin File Explorer
            * <b>(If Windows 11)</b> Configure ActiveSetup to import desktop-user-registry.reg using RunOnce
            * Software provisioning using chocolatey
                * Install Adobe Reader
                * Install Google Chrome
                * Install 7-Zip
                * Install Zoom
                * Install Microsoft Office 365
            * Create desktop shortcuts for
                * Adobe Reader
                * Excel
                * Word
            * Create scheduled task "Provisioning cleanup" that executed on startup
        * Provisioning cleanup scheduled task
            * Delete provisioning user
            * Remove "Provisioning cleanup" scheduled task
            * Remove autolong registry values
        * <b>(If Windows 11)</b> Import desktop-user-registry.reg (will repeat for each user on first logon)
            * Move taskbar icons to left
            * Remove chat, copilot, taskview from taskbar

## Prepare required files

* mediacreationtool.exe
* chocolatey-2.3.0.0.msi
* start2.bin
* desktop-provisioning.ps1
* desktop-upgrade.ps1
* desktop-cleanup.ps1
* oobe-setup.ps1

### Download files

* [Chocolatey](https://github.com/chocolatey/choco)
* [MediaCreationTool](https://www.microsoft.com/en-us/software-download/windows11)

### Create start menu file

<b>Install Microsoft Office:</b>

```batch
choco install office365business -y --no-progress --ignore-checksums
```

<b>Start layout location:</b>

```powershell
%LOCALAPPDATA%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\
```

## Create provisioning package

* Setup administrator accounts
    * admin1
    * admin2
* Setup computer name
* Configure wireless settings
* Set HideOobe value to True
* Package files
    * desktop-provisioning.ps1
    * desktop-upgrade.ps1
    * oobe-setup.ps1
* Configure oobe-setup.ps1 execution

<b>Computer name pattern:</b>

```
Xiente-%RAND:8%
```

<b>oobe-setup.ps1 execution:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

## Related videos

<b>PowerShell:</b>

* [PowerShell playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A)
* [Windows 11 set default applications for new users](https://youtu.be/K-o_iGZQPBo)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
* [Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu](https://youtu.be/lpbrQIvKGI4)