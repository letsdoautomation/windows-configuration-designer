# Perform offline domain join
$offline_djoin = ls (Get-PSDrive -PSProvider FileSystem).Root | ?{$_.Name -eq 'djoin'} | gci | sort name | select -first 1

if($null -ne $offline_djoin){
    djoin /requestodj /loadfile "$($offline_djoin.FullName)" /windowspath "$($env:SystemRoot)" /localos
    $offline_djoin.Delete()
}

exit 0