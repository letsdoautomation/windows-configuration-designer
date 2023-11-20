# Windows Configuration Designer
<b>Objectives:</b>

* Package software:
    * 7-Zip
    * Adobe Acrobat Reader DC
    * Blender
    * Brave
    * Cisco WebEx

* Skip OOBE
* Create admin user without password
* Add admin to Administrators group
* Skip "Privacy Experience"

## Packaging software

* [7-Zip](https://7-zip.org/download.html)
    * msiexec.exe /i "7z2301-x64.msi" /quiet /qn /norestart
* [Adobe Acrobat Reader DC](https://get.adobe.com/reader/enterprise/)
    * cmd /c AcroRdrDC2300320244_en_US.exe /sAll /rs /msi EULA_ACCEPT=YES
* [Blender](https://www.blender.org/)
    * cmd /c blender-3.6.2-windows-x64.msi /quiet /norestart ALLUSERS=1
* [Brave](https://github.com/brave/brave-browser)
    * cmd /c 
* [Cisco WebEx](https://www.webex.com/downloads.html)
    * cmd /c Webex_en.msi /quiet /norestart ALLUSERS=1