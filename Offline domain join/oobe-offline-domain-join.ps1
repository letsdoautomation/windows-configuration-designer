[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [String]$usb_name
)

$drive_letter = Get-Volume | ? { $_.FileSystemLabel -eq $usb_name } | select -expand DriveLetter

# Perform offline domain join
$offline_djoin = ls "$($drive_letter):\djoin" | sort name | select -first 1

if($null -ne $offline_djoin){
    djoin /requestodj /loadfile "$($offline_djoin.FullName)" /windowspath "$($env:SystemRoot)" /localos
    $offline_djoin.Delete()
}

exit 0