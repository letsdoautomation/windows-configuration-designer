# Windows Configuration Designer: Chocolatey and default applications

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

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```