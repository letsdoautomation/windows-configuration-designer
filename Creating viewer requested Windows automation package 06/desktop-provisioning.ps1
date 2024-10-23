


foreach ($language in "de-DE" , "hu-HU") {
    Install-Language -Language $language
}


switch(){
    
}

$domain_join = @{
    DomainName = 'ad.letsdoautomation.com'
    OUPath     = "OU=computers,OU=letsdoautomation,DC=ad,DC=letsdoautomation,DC=com"
    NewName    = "test01"
    #Credential = $credentials
}

if ($checkbox_restart.IsChecked) {
    $domain_join.Restart = $true
}

Add-Computer @domain_join