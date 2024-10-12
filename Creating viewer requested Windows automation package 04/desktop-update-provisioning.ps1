param(
    [switch]$first
)

$provisioning = [System.IO.DirectoryInfo]"$($env:ProgramData)\provisioning"

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

if ($first) {
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
        Value = "cmd /c powershell.exe -ExecutionPolicy Bypass -File {0}\desktop-update-provisioning.ps1" -f $provisioning.FullName
    }
    New-ItemProperty @setup_runonce | Out-Null
    Restart-Computer
}
else {
    # Software deployment
    $packages = 
    "googlechrome",
    "adobereader",
    "zoom",
    "firefox",
    'zoom',
    'Office365Business' -join " "

    $install_software_packages = @{
        FilePath     = "C:\ProgramData\chocolatey\choco.exe"
        ArgumentList = "install {0} -y --no-progress --ignore-checksums" -f $packages
        NoNewWindow  = $true
        PassThru     = $true
        Wait         = $true
    }
    
    Start-Process @install_software_packages

    # Domain join and 
    Add-Type -AssemblyName PresentationFramework

    [xml]$xaml = @"
<Window  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Let's do automation" Height="auto" Width="auto" SizeToContent="WidthAndHeight" >
    <StackPanel Orientation="Vertical" >
        <GroupBox Margin="5" Padding="10" Header="Join domain">
            <StackPanel Orientation="Vertical" >
                <TextBlock>Username:</TextBlock>
                <TextBox Name="input_username"></TextBox>
                <TextBlock>Password:</TextBlock>
                <PasswordBox Name="input_password"/>
                <CheckBox Name="checkbox_restart" IsChecked="False" Margin="10" Content="Restart computer" />
                <Button Name="button_join_domain" Content="Join Domain" />
            </StackPanel>
        </GroupBox>
        <GroupBox Margin="5" Padding="10" Header="Change current user password">
            <StackPanel Orientation="Vertical" >
                <TextBlock>Password:</TextBlock>
                <PasswordBox Name="input_local_user_password"/>
                <TextBlock>Repeat password:</TextBlock>
                <PasswordBox Name="input_repeat_local_user_password"/>
                <Separator Width="20" Background="Transparent"/>
                <Button Name="button_change_password" Content="Change Password" />
            </StackPanel>
        </GroupBox>
    </StackPanel>
</Window>
"@

    $window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

    # Domain join

    $input_username = $window.FindName('input_username')
    $input_password = $window.FindName('input_password')

    $checkbox_restart = $window.FindName('checkbox_restart')

    $button_join_domain = $window.FindName('button_join_domain')

    $button_join_domain.Add_Click(
        {
            if (![String]::IsNullOrEmpty($input_password.Password)) {
                $password = ConvertTo-SecureString $input_password.Password -AsPlainText -Force
                $credentials = New-Object System.Management.Automation.PSCredential ($input_username.Text, $password)
                # Modify
                $domain_join = @{
                    DomainName = 'ad.letsdoautomation.com'
                    OUPath     = "OU=computers,OU=letsdoautomation,DC=ad,DC=letsdoautomation,DC=com"
                    Credential = $credentials
                }

                if ($checkbox_restart.IsChecked) {
                    $domain_join.Restart = $true
                }

                Add-Computer @domain_join
            }
        }
    )

    $input_local_user_password = $window.FindName('input_local_user_password')
    $input_repeat_local_user_password = $window.FindName('input_repeat_local_user_password')

    $button_change_password = $window.FindName('button_change_password')

    $button_change_password.Add_Click(
        {
            if (![String]::IsNullOrEmpty($input_local_user_password.Password) -and
                $input_local_user_password.password -eq $input_repeat_local_user_password.password) {
                $local_user_password = ConvertTo-SecureString $input_local_user_password.Password -AsPlainText -Force
                try {
                    Get-LocalUser -Name $env:USERNAME | Set-LocalUser -Password $local_user_password -ErrorAction Stop
                    Write-Host "Password changed"
                }
                catch {
                    Write-Host $_.Exception.Message
                }
            }
            else {
                Write-Host "Password fields are empty or dont match"
            }
        }
    )

    $window.ShowDialog()
}
