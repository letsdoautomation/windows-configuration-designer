# Brave deployment
$brave_exe = 'BraveBrowserStandaloneSilentSetup.exe'

New-Item "$($env:ProgramData)\deployment_files\brave" -ItemType Directory -Force

cp $brave_exe "$($env:ProgramData)\deployment_files\brave\BraveBrowserStandaloneSilentSetup.exe" -Force

New-Item "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install brave" -Force

$reg_active_setup_install_brave = @{
    Path  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install brave"
    Name  = "StubPath"
    Value = 'reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v Installbrave /t REG_SZ /d "{0}\deployment_files\brave\BraveBrowserStandaloneSilentSetup.exe"' -f $env:ProgramData
    Force = $true
}

New-ItemProperty @reg_active_setup_install_brave