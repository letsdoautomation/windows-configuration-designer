param(
    [switch]$first
)

[IO.DirectoryInfo]$provisioning = "$($env:ProgramData)\provisioning"

[xml]$xaml = 
@"
<Window  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Let's do automation" Height="auto" Width="auto" SizeToContent="WidthAndHeight" >
    <StackPanel Orientation="Vertical" >
        <GroupBox Margin="5" Padding="10" Header="Set current user password">
            <StackPanel Orientation="Vertical" >
                <TextBlock>Password:</TextBlock>
                <PasswordBox Name="input_password" Margin="1"/>
                <Button Name="button_set_password" Margin="1" Content="Set" />
            </StackPanel>
        </GroupBox>
    </StackPanel>
</Window>
"@

# Wait for network connection
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


# Setup Windows Update powershell module for first run only
if ($first) {
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

$needs_restart = Get-WURebootStatus -Silent

if ($needs_restart) {
    $configure_runonce = @{
        Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name  = "execute_provisioning"
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File $($provisioning)\desktop-provisioning.ps1"
    }
    New-ItemProperty @configure_runonce | Out-Null
    Restart-Computer
}
else {
    # Registry configuration
    $settings +=
    [PSCustomObject]@{ # Lock computer after 10 minutes
        Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        Name  = "inactivitytimeoutsecs"
        Value = 600
    }

    foreach ($setting in ($settings | group Path)) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | % {
            $registry.SetValue($_.name, $_.value)
        }
        $registry.Dispose()
    }

    # Enable bitlocker
    $enable_bitlocker = @{
        MountPoint                = "C:\"
        RecoveryPasswordProtector = $true
        UsedSpaceOnly             = $true
    }

    Enable-BitLocker @enable_bitlocker

    # Execute batch file for defender activation
    $execute_batch = @{
        FilePath    = "$($provisioning.FullName)\defender.bat"
        Wait        = $true
        NoNewWindow = $true
    }
    Start-Process @execute_batch

    Add-Type -AssemblyName PresentationFramework

    $window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

    # Set password for current user
    $input_password = $window.FindName('input_password')
    $button_set_password = $window.FindName('button_set_password')

    $button_set_password.Add_Click(
        {
            $set_password = @{
                Password             = (ConvertTo-SecureString -AsPlainText $input_password.Password -Force)
                PasswordNeverExpires = $true
            }
        
            $user = Get-LocalUser -Name $env:username
            $user | Set-LocalUser @set_password

            $input_password.Password = $null
        }
    )

    $window.ShowDialog()

    Write-Host "All Done!" -ForegroundColor Green
    Read-Host
}
      