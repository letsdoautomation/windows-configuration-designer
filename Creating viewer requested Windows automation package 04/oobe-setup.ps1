# Create local admin account
$local_user = @{
    Name       = 'bplocal'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Name -notlike "chocolatey*"  -and $_.Name -ne "start2.bin"} | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Change computer name Set computer name to BP-%SERIAL%
$serial = "BP-{0}" -f ((gwmi -class win32_bios).SerialNumber -replace " ")

if($serial.length -gt 15){
    $serial = $serial.SubString(0, 14)
}

Rename-Computer -NewName $serial

# Install chocolatey
$chocolatey_msi_file = "chocolatey-2.3.0.0.msi"

$install_chocolatey = @{
    FilePath         = '{0}\system32\msiexec.exe' -f $env:SystemRoot
    ArgumentList     = '/i "{0}\{1}" /qn /norestart' -f (gl).path, $chocolatey_msi_file
    NoNewWindow      = $true
    PassThru         = $true
    Wait             = $true
}

Start-Process @install_chocolatey

# Configure default applications
$associations_xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".pdf" ProgId="AcroExch.Document.DC" ApplicationName="Adobe Acrobat Reader"/>
  <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
</DefaultAssociations>
"@

$associations_xml | Out-File "$($provisioning.FullName)\associations.xml" -Encoding utf8

dism /online /Import-DefaultAppAssociations:"$($provisioning.FullName)\associations.xml"

# Remove Windows store apps
$apps_to_leave = 
'Microsoft.DesktopAppInstaller', # fill fail removal
'Microsoft.SecHealthUI', # fill fail removal
"Microsoft.VCLibs.140.00", # fill re-install everything if removed
"Microsoft.Paint",
"Microsoft.Windows.Photos",
"Microsoft.WindowsCalculator",
"Microsoft.WindowsNotepad",
"Microsoft.WindowsTerminal"

Get-AppxProvisionedPackage -Online | ?{$_.DisplayName -notin $apps_to_leave} | Remove-AppxProvisionedPackage -Online -AllUser

# Prevent Outlook (new) and Dev Home from installing
"HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate",
"HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" | %{
    ri $_ -force
}

# Deploy start layout
[System.IO.FileInfo]$start_layout = ".\start2.bin"

ls "C:\Users\" -Attributes Directory -Force | ?{$_.FullName -notin $env:USERPROFILE, $env:PUBLIC -and $_.Name -notin "All Users", "Default User"} | %{

    [System.IO.DirectoryInfo]$destination = "$($_.FullName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

    if(!$destination.Exists){
        $destination.Create()
    }

    $start_layout.CopyTo("$($destination)\start2.bin", $true)
}
# Create user registry settings file
# Taskbar settings
# Desktop icons
$user_registry_settings = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000
"TaskbarAl"=dword:00000000
"ShowCopilotButton"=dword:00000000
"ShowTaskViewButton"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}]
@="$($serial)"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
"{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"=dword:00000000
"@

$user_registry_settings | Out-File "$($provisioning.FullName)\desktop-user-registry.reg" -Encoding unicode

$settings =
[PSCustomObject]@{ # Prevent OneDrive from installing
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\DisableOneDrive"
    Name  = "StubPath"
    Value = 'REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f'
},
[PSCustomObject]@{ # Skip privacy experiance
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
},
[PSCustomObject]@{ # Disable widgets
    Path  = "SOFTWARE\Policies\Microsoft\Dsh"
    Value = 0
    Name  = "AllowNewsAndInterests"
},
[PSCustomObject]@{ # Import desktop-user-registry.reg using ActiveSetup
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\ImportUserRegistry"
    Name  = "StubPath"
    Value = 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v ImportUserRegistry /d "REG IMPORT {0}" /f' -f "$($provisioning.FullName)\desktop-user-registry.reg"
},
[PSCustomObject]@{ # Execute desktop-provisioning.ps1 using ActiveSetup
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning"
    Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-update-provisioning.ps1 -First" -f $provisioning.FullName
} | group Path

foreach ($setting in $settings) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}
