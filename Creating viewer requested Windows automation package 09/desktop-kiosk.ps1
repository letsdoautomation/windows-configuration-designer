$execute_psexec = @{
    FilePath     = "$($env:ProgramData)\provisioning\PsExec.exe"
    ArgumentList = "-i -s -accepteula powershell.exe -ExecutionPolicy Bypass -File $($env:ProgramData)\provisioning\kiosk-configuration.ps1"
    NoNewWindow  = $true
    PassThru     = $true
    Wait         = $true
}
Start-Process @execute_psexec

Write-Host "All Done!" -ForegroundColor Green

Read-Host