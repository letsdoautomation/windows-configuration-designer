$software_packages = "$($env:ProgramData)\software_packages"

$packages =
[PSCustomObject]@{
    Name         = "7-Zip"
    Exe          = "7z2301-x64.exe"
    Type         = "Machine"
    SilentSwitch = "/S"
},
[PSCustomObject]@{
    Name         = "Adobe Reader"
    Exe          = "AcroRdrDC2300620360_en_US.exe"
    Type         = "Machine"
    SilentSwitch = "/sAll /rs /msi EULA_ACCEPT=YES"
},
[PSCustomObject]@{
    Name         = "Brave Browser"
    Exe          = "BraveBrowserStandaloneSilentSetup.exe"
    Type         = "User"
    SilentSwitch = ""
},
[PSCustomObject]@{
    Name         = "Google Chrome"
    Exe          = "googlechromestandaloneenterprise64.msi"
    Type         = "Machine"
    SilentSwitch = "/qn /norestart"
},
[PSCustomObject]@{
    Name         = "Telegram"
    Exe          = "tsetup-x64.4.11.1.exe"
    Type         = "User"
    SilentSwitch = "/VERYSILENT /NORESTART"
},
[PSCustomObject]@{
    Name         = "VLC"
    Exe          = "vlc-3.0.19-win64.exe"
    Type         = "Machine"
    SilentSwitch = "/S"
},
[PSCustomObject]@{
    Name         = "Firefox"
    Exe          = "Firefox Setup 119.0.exe"
    Type         = "Machine"
    SilentSwitch = "/S"
},
[PSCustomObject]@{
    Name         = "Zoom"
    Exe          = "ZoomInstallerFull.msi"
    Type         = "Machine"
    SilentSwitch = "/qn /norestart"
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