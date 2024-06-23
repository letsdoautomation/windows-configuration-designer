# Windows Configuration Designer: Chocolatey and default applications OPTION 1

<b>Downloads:</b>

* [Chocolatey](https://github.com/chocolatey/choco)

<b>Objectives:</b>

* Provision software with chocolatey
    * Google Chrome
    * Adobe Reader
    * 7-Zip
    * Notepad++
    * VLC
* Set default applications
    * Google Chrome as default browser
    * Adobe Reader as default PDF reader
* Perform all other actions to from OOBE setup to users desktop without user interaction
    * Skip OOBE
    * Skip "Privacy Experience"
    * Create user "admin" without password
    * Disable sleep

<b>Execution order:</b>

* <b>OOBE:</b>
    * Skip OOBE
    * Execute oobe-setup.ps1
        * Excute oobe-chocolatey.ps1
            * Install Chocolatey
            * Install Adobe Reader
            * Install Google Chrome
        * Execute oobe-associations.ps1
            * Set Google Chrome as default browser
            * Set Adobe Reader as default PDF reader
        * Create "admin" user without password
        * Skip "Privacy Experience" menu
        * Disable sleep
        * Configure Active Setup to execute desktop-provisioning.ps1

* <b>Script desktop-provisioning.ps1:</b>
  * Wait for network connection
  * Install 7-Zip
  * Install Notepad++
  * Install VLC

<b>Notes:</b>

* Package requires internet connection in OOBE

<b>Execute oobe-setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

## Related videos

<b>PowerShell:</b>

* [Windows 11 set default applications for new users](https://youtu.be/K-o_iGZQPBo)

<b>Windows Configuration Designer:</b>

* [Windows Configuration Designer: Downloading and installing](https://youtu.be/cSa12YaNMbU)
* [Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
