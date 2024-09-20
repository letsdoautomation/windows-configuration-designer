. .\oobe-software.ps1

# Prepare provisioning folder
$provisioning = ni "$($env:ProgramData)\provisioning" -ItemType Directory -Force

# Move files from provisioning package to provisioning folder
gci -File | ? { $_.Name -notlike "oobe-*" -and $_.Name -ne "start2.bin"} | % {
    cp $_.FullName "$($provisioning.FullName)\$($_.Name)" -Force
}

# Create Directory_A, Directory_B directory
"C:\Users\Default\Directory_A", 
"C:\Users\Default\Directory_B" | %{
  ni $_ -ItemType Directory
}

# Delete shortcuts from public Desktop
([System.IO.DirectoryInfo]"$($env:PUBLIC)").GetDirectories('Desktop').GetFiles('*.lnk').Delete()

# Configure default programs
@"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier="mailto" ProgId="Outlook.URL.mailto.15" ApplicationName="Outlook" />
  <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".pdf" ProgId="AcroExch.Document.DC" ApplicationName="Adobe Acrobat Reader"/>
  <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
</DefaultAssociations>
"@ | Out-File "$($provisioning.FullName)\associations.xml" -Encoding utf8

dism /online /Import-DefaultAppAssociations:"$($provisioning.FullName)\associations.xml"

# Deploy start layout
[System.IO.FileInfo]$start_layout = ".\start2.bin"

ls "C:\Users\" -Attributes Directory -Force | ?{$_.FullName -notin $env:USERPROFILE, $env:PUBLIC -and $_.Name -notin "All Users", "Default User"} | %{

    [System.IO.DirectoryInfo]$destination = "$($_.FullName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

    if(!$destination.Exists){
        $destination.Create()
    }

    $start_layout.CopyTo("$($destination)\start2.bin", $true)
}

# Create local admin account
$local_user = @{
    Name       = 'admin'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Administrators"

$settings =
[PSCustomObject]@{ 
    # Configure ActiveSetup to run user-commands.bat using RunOce
    # user-commands.bat will mute sound, delete desktop shortcuts from user profile, set screensaver and enable file extensions
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\ExecuteUserSettings"
    Name  = "StubPath"
    Value = 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v ImportUserRegistry /d "cmd /c {0}\user-commands.bat" /f' -f $provisioning.FullName
},
[PSCustomObject]@{ # Prevent OneDrive from installing
    Path  = "SOFTWARE\Microsoft\Active Setup\Installed Components\DisableOneDrive"
    Name  = "StubPath"
    Value = 'REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f'
},
[PSCustomObject]@{ # Skip privacy experiance
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE"
    Name  = "DisablePrivacyExperience"
    Value = 1
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