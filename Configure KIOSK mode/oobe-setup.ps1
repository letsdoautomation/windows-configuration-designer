# Create local kiosk user account
<# $local_user = @{
    Name       = 'Kiosk'
    NoPassword = $true
}

$user = New-LocalUser @local_user 
$user | Set-LocalUser -PasswordNeverExpires $true
 #>
# Set admin user password not to expire

# get-localuser "admin" | Set-LocalUser -PasswordNeverExpires $true