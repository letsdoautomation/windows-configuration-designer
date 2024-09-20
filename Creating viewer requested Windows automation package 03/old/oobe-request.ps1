[CmdletBinding()]
param(
  [Parameter(Mandatory = $True)]
  [System.IO.DirectoryInfo]$ProvisioningFolder
)

# mute volume
@"
CreateObject("WScript.Shell").SendKeys(chr(173))
"@ | Out-File "$($ProvisioningFolder.FullName)\mute.vbs"



# remove desktop shortcuts
ls "$($env:PUBLIC)\Desktop" | %{
  $_.Delete()
}

# configure default programs
# $ProvisioningFolder = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

%SystemDrive%\Users\Default\AppData\Local\Microsoft\Windows\Shell
# screensaver settings
# show file extensions
# mute
@"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Desktop]
"SCRNSAVE.EXE"="C:\\Windows\\system32\\ssText3d.scr"
"ScreenSaveTimeOut"="60"
"LockScreenAutoLockActive"="0"
"ScreenSaverIsSecure"="1"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Screensavers\ssText3d]
"AllScreensSame"=dword:00000000
"SurfaceType"=dword:00000001
"Specular"=dword:00000001
"SurfaceColor"=dword:00777777
"CustomTexture"=""
"CustomEnvironment"=""
"UseCustomColor"=dword:00000000
"UseCustomTexture"=dword:00000000
"UseCustomEnvironment"=dword:00000000
"MeshQuality"=dword:000001f4
"Size"=dword:0000000a
"RotationSpeed"=dword:0000000a
"RotationStyle"=dword:00000000
"DisplayTime"=dword:00000001
"FontWeight"=dword:00000000
"FontHeight"=dword:00000060
"FontItalic"=dword:01000000
"FontCharSet"=dword:00000001
"FontPitchFamily"=dword:61005400
"FontFace"="Tahoma"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce]
"mute"="cscript \"C:\\ProgramData\\provisioning\\mute.vbs\""
"@ | Out-File "$($ProvisioningFolder.FullName)\user-settings.reg"

ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\ImportUserSettings" | New-ItemProperty -Name "StubPath" -Value 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v ImportUserRegistry /d "REG IMPORT C:\ProgramData\provisioning\user-settings.reg" /f'

# prevent OneDrive from installing
ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\DisableOneDrive" | New-ItemProperty -Name "StubPath" -Value 'REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f'

