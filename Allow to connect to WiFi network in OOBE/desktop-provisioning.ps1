param(
    [System.IO.DirectoryInfo]$provisioning
)

$install_msi = @{
    FilePath     = "msiexec"
    ArgumentList = "/i $($provisioning.FullName)\googlechromestandaloneenterprise64.msi /qn /norestart"
    PassThru     = $true
    Wait         = $true
}
Start-Process @install_msi

Write-Host "Done" -BackgroundColor Green
Read-Host