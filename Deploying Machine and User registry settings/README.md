# Windows Configuration Designer: Deploying Machine and User registry settings

<b>Package contents:</b>

* Skip OOBE
* Execute setup.ps1
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