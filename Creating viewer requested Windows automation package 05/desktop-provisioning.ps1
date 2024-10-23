[CmdletBinding()]
param(
    [switch]$first,
    [Parameter(Mandatory = $True)]
    [System.IO.DirectoryInfo]$provisioning,
    [string]$username,
    [Parameter(Mandatory = $True)]
    [string]$password
)

$win_11_user_registry_settings = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000
"TaskbarAl"=dword:00000000
"ShowCopilotButton"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"@

$win_10_user_registry_settings = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"@

$taskbar_configuration = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Program Files\Google\Chrome\Application\chrome.exe" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE" />
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
 </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@

$default_program_configuration = @"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".ics" ProgId="Outlook.File.ics.15" ApplicationName="Outlook" />
  <Association Identifier=".mhtml" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".pdf" ProgId="Acrobat.Document.DC" ApplicationName="Adobe Acrobat" />
  <Association Identifier=".svg" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".xht" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".xhtml" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="mailto" ProgId="Outlook.URL.mailto.15" ApplicationName="Outlook" />
</DefaultAssociations>
"@

$win_10_start_menu_layout = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="">
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Notepad.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

# wait for network
$ProgressPreference_bk = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
do {
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if (!$ping) {
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while (!$ping)
$ProgressPreference = $ProgressPreference_bk

if ($First) {
    # setup windows update powershell module
    $nuget = Get-PackageProvider 'NuGet' -ListAvailable -ErrorAction SilentlyContinue

    if ($null -eq $nuget) {
        Install-PackageProvider -Name NuGet -Confirm:$false -Force
    }

    $module = Get-Module 'PSWindowsUpdate' -ListAvailable

    if ($null -eq $module) {
        Install-Module PSWindowsUpdate -Confirm:$false -Force
    }
}

# Install Windows updates
$updates = Get-WindowsUpdate

if ($null -ne $updates) {
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | select KB, Result, Title, Size
}

$status = Get-WURebootStatus -Silent

# Restart afer updating
if ($status) {
    
    $runonce_configuration = @{ # Configure RunOnce to rerun desktop-provisioning.ps1 after updates
        Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_update_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-provisioning.ps1 -provisioning $($provisioning.FullName) -username $($username) -password $($password)"
    },
    @{ # Enable autologon
        Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Name  = "AutoAdminLogon"
        Value = "1"
    },
    @{ # Set autologon username
        Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Name  = "DefaultUserName"
        Value = $username
    },
    @{ # Set autologon password
        Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Name  = "DefaultPassword"
        Value = $password
    }

    foreach($config in $runonce_configuration){
        New-ItemProperty @config -Force | Out-Null
    }
    
    Restart-Computer
}
else {
    # Configure regional settings
    Get-TimeZone -ListAvailable | ? { $_.DisplayName -like '*Eastern Time (US & Canada)*' } | Set-TimeZone

    # Create default application and taskbar configuration files
    $default_program_configuration | Out-File "$($provisioning.FullName)\associations.xml" -Encoding utf8 -Force -ea SilentlyContinue
    $taskbar_configuration | Out-File "$($provisioning.FullName)\taskbar.xml" -Encoding utf8 -Force -ea SilentlyContinue
    # Import default application configuration file
    dism /online /Import-DefaultAppAssociations:"$($provisioning.FullName)\associations.xml"

    $registry_settings = @()

    $registry_settings += [PSCustomObject]@{ # Prevent OneDrive from installing
        Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\DisableOneDrive"
        Value = 'REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f'
        Name  = "StubPath"
    },
    [PSCustomObject]@{ # Taskbar configuration
        Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
        Value = "{0}\{1}" -f $provisioning.FullName, "taskbar.xml"
        Name  = "StartLayoutFile"
        Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
    },
    [PSCustomObject]@{
        Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
        Value = 1
        Name  = "LockedStartLayout"
    },
    [PSCustomObject]@{ # Import desktop-user-registry.reg using ActiveSetup
        Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\ImportUserRegistry"
        Name  = "StubPath"
        Value = 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v ImportUserRegistry /d "REG IMPORT {0}" /f' -f "$($provisioning.FullName)\desktop-user-registry.reg"
    }

    # If Windows 10
    if ((gwmi Win32_OperatingSystem).Caption.Contains('Windows 10')) {
        # Import start menu layout
        $win_10_start_menu_layout | Out-File "$($provisioning.FullName)\win_10_start_menu_layout.xml" -Encoding utf8 -Force -ea SilentlyContinue
        Import-StartLayout -LayoutPath "$($provisioning.FullName)\win_10_start_menu_layout.xml" -MountPath "C:\"

        # Create desktop-user-registry.reg for Windows 10 users
        $win_10_user_registry_settings | Out-File "$($provisioning.FullName)\desktop-user-registry.reg" -Encoding unicode -Force
    }
    else {
        # If not Windows 10
        # Remove Home and Gallery from file explorer
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" | % {
            ri $_ -force -ea SilentlyContinue
        }

        # Create desktop-user-registry.reg for Windows 11 users
        $win_11_user_registry_settings | Out-File "$($provisioning.FullName)\desktop-user-registry.reg" -Encoding unicode -Force

        # Configure regional/locale/keyboard settings
        # For more details https://youtu.be/mshoCfPNUvM
        $keybaord = "en-us"

        Set-WinUserLanguageList $keybaord -force -wa silentlycontinue

        # Copy regional settings to new user accounts and welcome screen
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True

        # Prevent Outlook (new) and Dev Home from installing
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate",
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" | % {
            ri $_ -force -ea SilentlyContinue
        }

        # Deploy Windows 11 start menu
        [System.IO.FileInfo]$start_layout = "$($provisioning.FullName)\start2.bin"

        ls "C:\Users\" -Attributes Directory -Force | ? { $_.FullName -notin $env:PUBLIC -and $_.Name -notin "All Users", "Default User" } | % {

            [System.IO.DirectoryInfo]$destination = "$($_.FullName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

            if (!$destination.Exists) {
                $destination.Create()
            }

            $start_layout.CopyTo("$($destination)\start2.bin", $true)
        }

        $registry_settings += 
        [PSCustomObject]@{ # Remove Outlook (new)
            Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\RemoveOulookNew"
            Value = "REG ADD `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce`" /v RemoveOutlookNew /d `"cmd /c powershell -command Remove-AppxPackage (Get-AppxPackage).Where({`$_.name -eq 'Microsoft.OutlookForWindows'}).PackageFullName`" /f"
            Name  = "StubPath"
        }
    }

    # Both Windows 10 and Windows 11
    # Apply all registry settings
    $registry_settings = $registry_settings | group Path

    foreach ($setting in $registry_settings) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | % {
            if (!$_.Type) {
                $registry.SetValue($_.name, $_.value)
            }
            else {
                $registry.SetValue($_.name, $_.value, $_.type)
            }
        }
        $registry.Dispose()
    }

    # Chocolatey package deployment
    $packages = 
    "adobereader",
    "7zip.install",
    "googlechrome",
    "zoom" -join " "

    $install_software_packages = @{
        FilePath     = "C:\ProgramData\chocolatey\choco.exe"
        ArgumentList = "install {0} -y --no-progress --ignore-checksums" -f $packages
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    
    Start-Process @install_software_packages

    # Microsoft Office 365 deployment
    $install_m365_office = @{
        FilePath     = "C:\ProgramData\chocolatey\choco.exe"
        ArgumentList = "install office365business --params `"'/productid:O365ProPlusRetail /exclude:OneDrive'`" -y --no-progress --ignore-checksums"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }

    Start-Process @install_m365_office

    # Remove Windows store apps
    $app_packages = 
    "Microsoft.WindowsCamera",
    "Clipchamp.Clipchamp",
    "Microsoft.WindowsAlarms",
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.WindowsFeedbackHub",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsMaps",
    "Microsoft.ZuneMusic",
    "Microsoft.BingNews",
    "Microsoft.Todos",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "MicrosoftCorporationII.QuickAssist",
    "Microsoft.ScreenSketch",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.BingWeather",
    "Microsoft.Xbox.TCUI",
    "Microsoft.GamingApp",
    "Microsoft.Windows.Ai.Copilot.Provider",
    "MSTeams",
    "Microsoft.Windows.DevHome",
    "Microsoft.SkypeApp",
    "Microsoft.Office.OneNote",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MSPaint",
    "Microsoft.XboxApp"
        
    Get-AppxProvisionedPackage -Online | ? { $_.DisplayName -in $app_packages } | Remove-AppxProvisionedPackage -Online -AllUser -ea SilentlyContinue

    # Create desktop shortcuts
    $shortcuts = 
    [PSCustomObject]@{
        TargetPath = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
        Location   = "$($env:PUBLIC)\Desktop\Word.lnk"
    },
    [PSCustomObject]@{
        TargetPath = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
        Location   = "$($env:PUBLIC)\Desktop\Excel.lnk"
    },
    [PSCustomObject]@{
        TargetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Adobe Acrobat.lnk"
        Location   = "$($env:PUBLIC)\Desktop\Adobe Acrobat.lnk"
    }

    foreach ($shortcut in $shortcuts) {
        $shell = New-Object -comObject WScript.Shell
        $create_shortcut = $shell.CreateShortcut($shortcut.Location)
        $create_shortcut.TargetPath = $shortcut.TargetPath
        $create_shortcut.Save()
    }

    # Remove autologon information
    "AutoAdminLogon", "DefaultUserName", "DefaultPassword" | % {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name $_ -ErrorAction SilentlyContinue
    }

    # Remove provisioning user
    Remove-LocalUser $env:USERNAME

    Write-Host "All Done! Press Enter to restart" -ForegroundColor Green
    Read-Host
    Restart-Computer
}