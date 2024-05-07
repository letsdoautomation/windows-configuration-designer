@'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=dword:00000000
'@ | Out-File "$($env:ProgramData)\provisioning\desktop-user-registry.reg" -Encoding utf8

ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\ImportUserRegistry" | New-ItemProperty -Name "StubPath" -Value 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v ImportUserRegistry /d "REG IMPORT C:\ProgramData\provisioning\desktop-user-registry.reg" /f'