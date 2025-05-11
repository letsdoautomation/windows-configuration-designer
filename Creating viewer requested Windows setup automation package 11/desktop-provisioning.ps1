foreach ($app in ([IO.DirectoryInfo]"$($env:ProgramData)\provisioning").getFiles().Where({ $_.Extension -in '.msixbundle', '.appx' })) {
    $add_appx_provisioned_package = @{
        Online      = $true
        PackagePath = $app.FullName
        SkipLicense = $true
    }
    Add-AppxProvisionedPackage @add_appx_provisioned_package
}

Write-Host "All done." -BackgroundColor Green
Read-Host