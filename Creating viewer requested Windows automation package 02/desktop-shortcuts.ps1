$shortcuts = 
[PSCustomObject]@{
    TargetPath = "C:\ProgramData\provisioning\TeamViewerQS_x64.exe"
    Location   = "$($env:PUBLIC)\Desktop\TeamViewerQS_x64.lnk"
},
[PSCustomObject]@{
    TargetPath = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
    Location   = "$($env:PUBLIC)\Desktop\Word.lnk"
},
[PSCustomObject]@{
    TargetPath = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
    Location   = "$($env:PUBLIC)\Desktop\Excel.lnk"
},
[PSCustomObject]@{
    TargetPath = "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
    Location   = "$($env:PUBLIC)\Desktop\Adobe Acrobat.lnk"
}

foreach ($shortcut in $shortcuts) {
    $shell = New-Object -comObject WScript.Shell
    $create_shortcut = $shell.CreateShortcut($shortcut.Location)
    $create_shortcut.TargetPath = $shortcut.TargetPath
    $create_shortcut.Save()
}