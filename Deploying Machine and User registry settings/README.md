# Windows Configuration Designer: Deploying Machine and User registry settings

<b>Package contents:</b>

* Skip OOBE
* Execute oobe-setup.ps1
    * Execute oobe-machine-registry.ps1
        * Hide task view
        * Disable widgets
        * Remove Home and Gallery from explorer
    * Execute oobe-user-registry.ps1
        * Configure ActiveSetup to import desktop-user-registry.reg via RunOnce
            * Enable old right click menu
            * Move taskbar items to left
            * Remove search bar from taskbar
    * Skip Privacy Experiance
    * Create local administrators account
    * Configure Power Settings

<b>Execute setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

### Related videos

<b>Playlists:</b>

* [Windows 11 settings](https://www.youtube.com/playlist?list=PLVncjTDMNQ4St7rvA0w_nuv5CHxBccoLJ) <br />
* [Windows Configuration Designer](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2) <br />
* [PowerShell](https://www.youtube.com/playlist?list=PLVncjTDMNQ4RDyVzbV0_kpXCScTMgUw_A) <br />
* [Windows Registry](https://www.youtube.com/playlist?list=PLVncjTDMNQ4TZrwwuYuZBZhpjs6YWw7sQ) <br />