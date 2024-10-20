[CmdletBinding()]
param(
    [switch]$First,
    [Parameter(Mandatory = $True)]
    [System.IO.DirectoryInfo]$provisioning
)

# Create taskbar configuration file
@"
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
"@ | Out-File "$($provisioning.FullName)\taskbar.xml" -Encoding utf8 -Force -ea SilentlyContinue

# Create default programs configuration file
@"
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
"@ | Out-File "$($provisioning.FullName)\associations.xml" -Encoding utf8 -Force -ea SilentlyContinue

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

# install windows updates
$updates = Get-WindowsUpdate

if ($null -ne $updates) {
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | select KB, Result, Title, Size
}

$status = Get-WURebootStatus -Silent

if ($status) {
    $setup_runonce = @{
        Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_update_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-provisioning.ps1" -f $provisioning.FullName
    }
    New-ItemProperty @setup_runonce | Out-Null
    Restart-Computer
}
else {
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
    "MSTeams", # From here start apps that come from upgrading from Windows 10
    "Microsoft.Windows.DevHome",
    "Microsoft.SkypeApp",
    "Microsoft.Office.OneNote",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MSPaint"
    #"Microsoft.OutlookForWindows"

    Get-AppxProvisionedPackage -Online | ? { $_.DisplayName -in $app_packages } | Remove-AppxProvisionedPackage -Online -AllUser

    # Configure regional settings
    Get-TimeZone -ListAvailable | ? { $_.DisplayName -like '*Eastern Time (US & Canada)*' } | Set-TimeZone

    dism /online /Import-DefaultAppAssociations:"$($provisioning.FullName)\associations.xml"

    $settings = @()

    $settings += [PSCustomObject]@{ # Prevent OneDrive from installing
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
    }

    # IF Windows 11
    if ((Get-WmiObject Win32_OperatingSystem).Caption -notmatch "Windows 10") {

        # Remove gallery and home from file explorer
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" | % {
            ri $_ -force -ea SilentlyContinue
        }

        # configure regional/locale/keyboard settings
        # for more details https://youtu.be/mshoCfPNUvM
        $keybaord = "en-us"

        Set-WinUserLanguageList $keybaord -force -wa silentlycontinue

        # copy regional settings to new user accounts and welcome screen
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True

        # Prevent Outlook (new) and Dev Home from installing
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate",
        "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" | % {
            ri $_ -force -ea SilentlyContinue
        }

        # Deploy start menu layout
        [System.IO.FileInfo]$start_layout = "$($provisioning.FullName)\start2.bin"

        ls "C:\Users\" -Attributes Directory -Force | ? { $_.FullName -notin $env:PUBLIC -and $_.Name -notin "All Users", "Default User" } | % {

            [System.IO.DirectoryInfo]$destination = "$($_.FullName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

            if (!$destination.Exists) {
                $destination.Create()
            }

            $start_layout.CopyTo("$($destination)\start2.bin", $true)
        }

        $settings += [PSCustomObject]@{ # Import desktop-user-registry.reg using ActiveSetup
            Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\ImportUserRegistry"
            Name  = "StubPath"
            Value = 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v ImportUserRegistry /d "REG IMPORT {0}" /f' -f "$($provisioning.FullName)\desktop-user-registry.reg"
        },
        [PSCustomObject]@{ # Remove Outlook (new)
            Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\RemoveOulookNew"
            Value = "REG ADD `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce`" /v RemoveOutlookNew /d `"cmd /c powershell -command Remove-AppxPackage (Get-AppxPackage).Where({`$_.name -eq 'Microsoft.OutlookForWindows'}).PackageFullName`" /f"
            Name  = "StubPath"
        }
    }
    # Both Windows 10 and Windows 11

    $settings = $settings | group Path

    foreach ($setting in $settings) {
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

    # Software deployment
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

    # Install Office 365
    $install_m365_office = @{
        FilePath     = "C:\ProgramData\chocolatey\choco.exe"
        ArgumentList = "install office365business --params `"'/productid:O365ProPlusRetail /exclude:OneDrive'`" -y --no-progress --ignore-checksums"
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }

    Start-Process @install_m365_office

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
    
    # Create scheduled task to remove provisioning user and task itself
    $actions = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $($provisioning.FullName)\desktop-cleanup.ps1"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger 

    Register-ScheduledTask "Provisioning cleanup" -InputObject $task
    
    # Remove autologon information
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -ErrorAction SilentlyContinue


    Write-Host "All Done! Press Enter to restart" -ForegroundColor Green
    Read-Host
    Restart-Computer
}