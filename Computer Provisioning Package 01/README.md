# Windows Configuration Designer: Computer Provisioning Package 01

<b>Provisioning setup:</b>

* provisioning package actions:
    * Skip OOBE
    * Offline install Chocolatey
    * Execute setup.ps1
        * Disable privacy experience
        * Create local admin account <b>without password</b>
        * Disable sleep on AC
        * Copy all configuration scripts from provisioning package to computer
        * Setup RunOnce to execute provisioning.ps1 after <b>admin user logon</b>

* provisioning.ps1 actions:
    * Configure software:
        * Configure Brave
        * Configure Google Chrome
        * Configure Edge
        * Configure Firefox
    * Perform Windows Updates
    * Install software packages with chocolatey from community repository:
        * Google Chrome
        * Firefox
    * Install custom software packages with chocolatey from usb drive:
        * Brave
    * Perform <b>OPTIONAL</b> steps:
        * Create local admin account
        * Change computer name
        * Reboot computer

## Package setup:
<b>Install Chocolatey:</b>

* [Chocolatey](https://github.com/chocolatey/choco) <br /><br />

<b>Execute chocolatey installation:</b>

```powershell
# Make sure that executable name is correct
msiexec.exe /i chocolatey-2.2.2.0.msi /qn /norestart
```

<b>Execute setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File setup.ps1
```

## Related content:
* <b>Windows Configuration Desiner:</b>
    * [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* <b>Brave package:</b>
    * [Chocolatey: Create Brave Browser software deployment package](https://youtu.be/8qla8rqSuAo)
* <b>Configuring web browser settings with powershell:</b>
    * [Firefox settings](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SCsMyYad3CO0erlh-mGwiM)
    * [Brave Browser settings](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RR2YCyeUAg9u0UX_qXWtkA)
    * [Microsoft Edge settings](https://www.youtube.com/playlist?list=PLVncjTDMNQ4QwvLOskFdmFz_rZUKdgTW6)
    * [Google Chrome settings](https://www.youtube.com/playlist?list=PLVncjTDMNQ4QNF4Npbo_eUzOUT_p6Or2k)
* <b>Windows registry:</b>
    * [Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo)
    * [Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw)
* <b>Chocolatey:</b>
    * [Chocolatey: Installing and basic commands](https://youtu.be/vEH7t5eqJq4)
    * [Chocolatey: Exploring chocolatey.org repository and packages](https://youtu.be/grbsYDEyCQ0)
    * <b>Creating chocolatey packages:</b>
        * [Chocolatey](https://www.youtube.com/playlist?list=PLVncjTDMNQ4TMCZqT4EJEtOGzwj6pvQKl)