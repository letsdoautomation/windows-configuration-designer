$software_packages = "$($env:ProgramData)\software_packages"

$packages =
[PSCustomObject]@{
    Name         = ""
    Exe          = ""
    Type         = ""
    SilentSwitch = ""
}

foreach ($package in $packages) {
    switch ($package.Type) {
        "Machine" {
            Write-Host "Executing $($package.Name)"

            if($package.exe -Like "*.msi"){
                $execute = @{
                    FilePath         = "msiexec"
                    ArgumentList     = "/i $($software_packages)\$($package.exe) $($package.SilentSwitch)"
                    NoNewWindow      = $true
                    PassThru         = $true
                    Wait             = $true
                }
            }
            else{
                $execute = @{
                    FilePath         = "$($software_packages)\$($package.exe)"
                    ArgumentList     = $package.SilentSwitch
                    NoNewWindow      = $true
                    PassThru         = $true
                    Wait             = $true
                }
            }

            $result = Start-Process @execute

            Write-Host "    ExitCode: $($result.ExitCode)"

            rm "$($software_packages)\$($package.exe)" -Force

            break
        }
        "User" {
            Write-Host "Setting up $($package.Name) for user wide installation"
            if([string]::IsNullOrEmpty($package.SilentSwitch)){
                ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install $($package.Name)" | New-ItemProperty -Name StubPath -Value ('REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Install {0}" /t REG_SZ /d "{1}"' -f $package.Name, "$($software_packages)\$($package.exe)") | Out-Null
            }
            else{
                ni "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\Install $($package.Name)" | New-ItemProperty -Name StubPath -Value ('REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Install {0}" /t REG_SZ /d "{1} {2}"' -f $package.Name, "$($software_packages)\$($package.exe)", $package.SilentSwitch) | Out-Null
            }
            break
        }
    }
}

Write-Host "All Done"
Read-Host