[IO.DirectoryInfo]$provisioning = "$($env:ProgramData)\provisioning"

# Configure wallpaper
# credit goes to Jose Espitia:
# https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/

$type_definition = 
@" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 

Function Set-WallPaper($Image) {  
    Add-Type -TypeDefinition $type_definition
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
 
}
 
Set-WallPaper -Image "$($provisioning.FullName)\wallpaper.png"


# Rempve Copilot
$remove_package =
"Microsoft.Copilot",
"Microsoft.OutlookForWindows"

Get-AppxPackage | ? { $_.name -in $remove_package } | Remove-AppPackage