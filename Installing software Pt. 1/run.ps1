# WinRAR Deployment
# Make sure that executable name is correct
$winrar_exe = 'winrar-x64-623.exe'
$winrar_silent_args = '/S'

$winrar_path = gi $winrar_exe | select -expand FullName

$install_params = @{
    FilePath     = 'PsExec.exe'
    ArgumentList = "-accepteula -i -s $($winrar_path) $($winrar_silent_args)"
    NoNewWindow  = $true
    Wait         = $true
}

Start-Process @install_params

New-Item "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\WinRAR run once" -Force

$reg_active_setup_run_winrar = @{
    Path  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\WinRAR run once"
    Name  = "StubPath"
    Value = 'reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v RunWinRAR /t REG_SZ /d "{0}\WinRAR\WinRAR.exe"' -f $env:ProgramFiles
    Force = $true
}

New-ItemProperty @reg_active_setup_run_winrar

# Telegram Deployment
# Make sure that executable name is correct
$telegram_exe = 'tsetup-x64.4.9.2.exe'
$telegram_args = '/VERYSILENT /NORESTART'

New-Item "$($env:ProgramData)\deployment_files\telegram" -ItemType Directory -Force

cp $telegram_exe "$($env:ProgramData)\deployment_files\telegram\tsetup.exe" -Force

New-Item "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install telegram" -Force

$reg_active_setup_install_telegram = @{
    Path  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install telegram"
    Name  = "StubPath"
    Value = 'reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v InstallTelegram /t REG_SZ /d "{0}\deployment_files\telegram\tsetup.exe {1}"' -f $env:ProgramData, $telegram_args
    Force = $true
}

New-ItemProperty @reg_active_setup_install_telegram
