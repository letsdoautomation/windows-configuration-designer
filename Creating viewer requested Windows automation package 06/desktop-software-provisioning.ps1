$install_msi = @{
    FilePath     = "msiexec"
    ArgumentList = "/i $($env:ProgramData)\provisioning\googlechromestandaloneenterprise64.msi /qn /norestart"
    PassThru     = $true
    Wait         = $true
}
Start-Process @install_msi

Write-Host "Done" -BackgroundColor Green
Read-Host