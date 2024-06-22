param(
    [string]$Path
)

$software_packages = 
[pscustomobject]@{
    Executable = '{0}\AcroRdrDC2400220857_en_US.exe' -f $Path
    Arguments  = '/sAll /rs /msi EULA_ACCEPT=YES'
},
[pscustomobject]@{
    Executable = '{0}\googlechromestandaloneenterprise64.msi' -f $Path
    Arguments  = '/qn /norestart'
}

foreach ($package in $software_packages) {
    if ([System.IO.Path]::GetExtension($package.Executable) -eq '.msi') {
        $execute = @{
            FilePath     = "msiexec"
            ArgumentList = "/i {0} {1}" -f $package.Executable, $package.Arguments
            NoNewWindow  = $true
            PassThru     = $true
            Wait         = $true
        }
    }
    elseif ([System.IO.Path]::GetExtension($package.Executable) -eq '.exe') {
        $execute = @{
            FilePath         = $package.Executable
            ArgumentList     = $package.Arguments
            NoNewWindow      = $true
            PassThru         = $true
            Wait             = $true
        }
    }
    Start-Process @execute
}