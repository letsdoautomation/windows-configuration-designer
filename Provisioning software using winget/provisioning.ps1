# Update winget
ls "$($env:ProgramData)\provisioning\Microsoft.VCLibs.x64.*", 
"$($env:ProgramData)\provisioning\Microsoft.UI.Xaml.*", 
"$($env:ProgramData)\provisioning\Microsoft.DesktopAppInstaller_*" | %{
    "Updating $($_.Name)" | Out-Host
    Add-AppxPackage $_.FullName -ErrorAction SilentlyContinue
}

# Wait for network
do{
    $ping = Test-NetConnection '8.8.8.8' -InformationLevel Quiet
    if(!$ping){
        cls
        'Wainting for network connection' | Out-Host
        sleep -s 5
    }
} while(!$ping)

# Scope user or machine
$scope = 'machine'

$packages = 
[PSCustomObject]@{
    Name  = "Adobe.Acrobat.Reader.64-bit"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "Microsoft.Teams.Classic"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "Google.Chrome"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "7zip.7zip"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "Mozilla.Firefox"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "Zoom.Zoom"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "Microsoft.VisualStudioCode"
    Scope = $scope
},
[PSCustomObject]@{
    Name  = "VideoLAN.VLC"
    Scope = $null
}

$packages | % {
    if ($_.Scope) {
        winget install -e --id $_.Name --scope 'machine' --silent --accept-source-agreements
    }
    else {
        winget install -e --id $_.Name --silent --accept-source-agreements
    }
}


Write-Host "All Done!" -ForegroundColor Green
Read-Host