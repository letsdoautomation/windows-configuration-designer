param(
    [Parameter(Mandatory = $True)]
    [string]$domain_username,
    [Parameter(Mandatory = $True)]
    [string]$domain_password,
    [Parameter(Mandatory = $True)]
    [string]$domain_name,
    [switch]$first
)

$password = ConvertTo-SecureString $domain_password -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential ($domain_username, $password)

# Modify
$domain_join = @{
    DomainName = $domain_name
    OUPath     = $null
    Credential = $pscredential
}

$registry_settings +=
[PSCustomObject]@{ # Enable autologon
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "AutoAdminLogon"
    Value = "1"
},
[PSCustomObject]@{ # Set autologon username
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultUserName"
    Value = $domain_username
},
[PSCustomObject]@{ # Set autologon password
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultPassword"
    Value = $domain_password
},
[PSCustomObject]@{ # Set autologon domain
    Path  = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Name  = "DefaultDomainName"
    Value = $domain_name
}

foreach ($language in "de-DE" , "hu-HU") {
    Install-Language -Language $language
}

Add-Type -AssemblyName PresentationFramework
[xml]$xaml =
@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Let's do automation" Height="auto" Width="auto" SizeToContent="WidthAndHeight" Topmost="True"
        WindowStartupLocation="CenterScreen" >
    <StackPanel Orientation="Vertical">
        <GroupBox Header="Configure computer name">
            <StackPanel Orientation="Vertical">
                <TextBlock>
                    Name:    
                </TextBlock>
                <TextBox Name="input_computer_name" />
                <CheckBox Name="checkbox_restart" IsChecked="True" Content="Restart Computer" Margin="10" />
                <Button Name="button_join_and_rename" Content="Join and rename" />
            </StackPanel>
        </GroupBox>
    </StackPanel>
</Window>
"@
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

$input_computer_name = $window.FindName('input_computer_name')
$checkbox_restart = $window.FindName('checkbox_restart')

$window.FindName('button_join_and_rename').Add_Click(
    {
        $rename_computer = @{
            DomainCredential = $pscredential
            NewName          = $input_computer_name.Text
        }
        switch -wildcard ($input_computer_name.Text) {
            "AA-*" {
                $domain_join.OUPath = "OU=Computers,OU=Domain,DC=ad,DC=letsdoautomation,DC=com"
            }
        }

        Add-Computer @domain_join
    
        if ($checkbox_restart.IsChecked) {
            $rename_computer.Restart = $true
        }

        # Apply registry settings
        foreach ($setting in ($registry_settings | group Path)) {
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
        Disable-LocalUser -Name $env:USERNAME
        Rename-Computer @rename_computer
    }
)
$window.ShowDialog()