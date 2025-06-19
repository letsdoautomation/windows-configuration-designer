$settings = @()

# Create local admin account
$local_user = @{
    Name       = 'admin'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

# Create C:\ProgramData\provisioning directory
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Extension -ne '.msi' } | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Configure default applications
$create_associations_xml_file = @{
    FilePath = "$($provisioning.FullName)\associations.xml"
    Encoding = "UTF8"
}

$import_associations_xml_file = @{
    FilePath     = "dism"
    ArgumentList = "/online", '/Import-DefaultAppAssociations:"{0}\associations.xml' -f $provisioning.FullName
    Wait         = $true
}

@"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".pdf" ProgId="ChromeHTML" ApplicationName="Google Chrome"/>
  <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
</DefaultAssociations>
"@ | Out-File @create_associations_xml_file

Start-Process @import_associations_xml_file

# Remove Windows store applications
$remove_package = 
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
"Microsoft.OutlookForWindows",
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
"Microsoft.Copilot"

Get-AppxProvisionedPackage -Online | ? { $_.DisplayName -in $remove_package } | Remove-AppxProvisionedPackage -Online -AllUser

# Prevent Outlook (new) from installing for older Windows 11 versions
"HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate" | % {
    ri $_ -force
}

# Install msi files
$msi_installation_files = 
"gcpwstandaloneenterprise64.msi",
"chocolatey-2.4.3.0.msi"

foreach ($msi_file in $msi_installation_files) {
    $install_msi = @{
        FilePath     = '{0}\system32\msiexec.exe' -f $env:SystemRoot
        ArgumentList = '/i "{0}\{1}" /qn /norestart' -f (gl).path, $msi_file
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    Start-Process @install_msi
}

# Install chocolatey packages
$chocolatey_packages =
'googlechrome',
'googledrive' -join " "

$install_chocolatey_packages = @{
    FilePath     = "C:\ProgramData\chocolatey\choco.exe"
    ArgumentList = "install {0} -y --no-progress --ignore-checksums" -f $chocolatey_packages
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}
Start-Process @install_chocolatey_packages

# Create "Chrome remote desktop" shortcut
$shell = New-Object -comObject WScript.Shell
$shortcut = $shell.CreateShortcut("$($provisioning.FullName)\Chrome Remote Desktop.lnk")
$shortcut.TargetPath = "C:\Program Files\Google\Chrome\Application\chrome_proxy.exe"
$shortcut.Arguments = " --profile-directory=Default --app-id=cmkncekebbebpfilplodngbpllndjkfo"
$shortcut.WindowStyle = '1'
$shortcut.WorkingDirectory = "C:\Program Files\Google\Chrome\Application"
$shortcut.IconLocation = "$($provisioning.FullName)\icon_48px.ico,0"
$shortcut.Save()

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
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Program Files\Google\Chrome\Application\chrome.exe" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="$($provisioning.FullName)\Chrome Remote Desktop.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
 </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@ | Out-File "$($provisioning.FullName)\taskbar.xml" -Encoding utf8

# Registry configuration
$settings +=
[PSCustomObject]@{ # Install Google Chrome remote desktop extension
    Path  = "SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
    Name  = "1"
    Value = "inomeogfingihgjfjlpeplalcfajhgai"
},
[PSCustomObject]@{  # Install Google Chrome remote desktop PWA
    Path  = "SOFTWARE\Policies\Google\Chrome"
    Value = ConvertTo-Json @(
        @{
            create_desktop_shortcut  = $false
            default_launch_container = "window"
            url                      = "https://remotedesktop.google.com/"
        }
    ) -Compress
    Name  = "WebAppInstallForceList"
},
[PSCustomObject]@{ # Disable privacy experiance
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
},
[PSCustomObject]@{ # Configure taskbar
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = "$($provisioning.FullName)\taskbar.xml"
    Name  = "StartLayoutFile"
    Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
},
[PSCustomObject]@{ # Configure taskbar
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = 1
    Name  = "LockedStartLayout"
},
[PSCustomObject]@{ # Execute desktop-user-activesetup.ps1
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\UserProvisioning"
    Name  = "StubPath"
    Value = 'powershell.exe -Command "gc {0}\desktop-user-activesetup.ps1 -Raw | iex"' -f $provisioning.FullName
},
[PSCustomObject]@{ # Execute desktop-provisioning.ps1
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Name  = "execute_provisioning"
    Value = "powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-provisioning.ps1 -First" -f $provisioning.FullName
},
[PSCustomObject]@{ 
    # Prevent Windows from pinning Outlook (new) to taskbar
    # and disable other cloud content features
    Path  = "SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    Name  = "DisableCloudOptimizedContent"
    Value = 1
},
[PSCustomObject]@{ # Enable Get Latest Updates as soon as they're available
    Path  = "SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    Name  = "IsContinuousInnovationOptedIn"
    Value = 1
},
[PSCustomObject]@{ # GCPW enrollment token
    Path  = "SOFTWARE\Policies\Google\CloudManagement"
    Name  = "EnrollmentToken"
    Value = "xxxxxxxxxxxxxxxxxxxxxxx"
}

foreach ($setting in ($settings | group Path)) {
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

# Configure power settings
"powercfg /x -monitor-timeout-ac 0",
"powercfg /x -standby-timeout-ac 0" | % {
    cmd /c $_
}