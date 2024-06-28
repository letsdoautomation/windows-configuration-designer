Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Let's do automation" Height="auto" Width="auto" SizeToContent="WidthAndHeight" >
    <StackPanel Orientation="Vertical" >
        <GroupBox Margin="5" Padding="10" Header="Create local user">
            <StackPanel Orientation="Vertical" >
                <TextBlock>Username:</TextBlock>
                <TextBox Name="input_username"></TextBox>
                <TextBlock>Password:</TextBlock>
                <PasswordBox Name="input_password"/>
                <CheckBox Name="checkbox_administrator" IsChecked="True" Margin="10" Content="Add to Administrators group" />
                <Button Name="button_create_user" Content="Create" />
            </StackPanel>
        </GroupBox>
        <GroupBox Margin="5" Padding="10" Header="Change computer name">
            <StackPanel Orientation="Vertical" >
                <TextBlock>Computer name:</TextBlock>
                <TextBox Name="input_computer_name"></TextBox>
                <CheckBox Name="checkbox_restart" IsChecked="True" Margin="10" Content="Restart computer" />
                <Button Name="button_rename_computer" Content="Change" />
            </StackPanel>
        </GroupBox>
    </StackPanel>
</Window>
"@

$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

# User creation

$input_username = $window.FindName('input_username')
$input_password = $window.FindName('input_password')

$checkbox_administrator = $window.FindName('checkbox_administrator')

$button_create_user = $window.FindName('button_create_user')

$button_create_user.Add_Click(
    {

        if (![String]::IsNullOrEmpty($input_password.Password)) {
            $new_user = @{
                Name     = $input_username.Text
                Password = (ConvertTo-SecureString -AsPlainText $input_password.Password -Force)
            }
        } 
        else {
            $new_user = @{
                Name       = $input_username.Text
                NoPassword = $true
            }
        }

        "Creating user {0}" -f $input_username.Text | Out-Host

        $user = New-LocalUser @new_user
        $user | Set-LocalUser -PasswordNeverExpires $true 

        if ($checkbox_administrator.IsChecked) {
            $user | Add-LocalGroupMember -Group "Administrators"
        }
        else{
            $user | Add-LocalGroupMember -Group "Users"
        }

        $input_username.Text = $null
        $input_password.Password = $null
    }
)

# Computer name change

$input_computer_name = $window.FindName('input_computer_name')
$input_computer_name.Text = $env:COMPUTERNAME

$checkbox_restart = $window.FindName('checkbox_restart')

$button_rename_computer = $window.FindName('button_rename_computer')


$button_rename_computer.Add_Click(
    {
        $rename = @{
            NewName = $input_computer_name.Text
            Restart = $false
        }

        if ($checkbox_restart.IsChecked) {
            $rename.Restart = $true
        }
        Rename-Computer @rename
    }
)

$window.ShowDialog()