<#Update Varonis Credentials
- Filewalk
- AD Walk
- Collectors
- Probe proxies

Verified on DA v6.0.112; pre-6.0.112 requires patch 377395 in order to set collector credentials


#>

#new credentials (AD walk, File walk, Collector working share, probe proxy working credentials)
$newUser = "jt\nithil" #UPDATE THIS LINE
$newPW = "password1" #UPDATE THIS LINE

#collector host credential (must be a LOCAL ADMIN with LOG ON RIGHTS on ALL collectors)
$admColUser = "jt\jonathan" #UPDATE THIS LINE
$admColPW = "password1" #UPDATE THIS LINE

#connect to IDU
Import-Module VaronisManagement
">> Connecting to IDU.."
Connect-IDU

$newCred = New-VaronisCredential -username $newUser -password $newPW
$installCred = New-VaronisCredential -username $admColUser -password $admColPW

# [1] Update filewalk credentials on ALL file servers
"----------"
"Updating Filewalk Credentials"
$filers = Get-FileServer #gets filer IDs
$filers | foreach-object {
    $hostname = ""
    $filerID = ""

    $filer = $_
    $hostname = $_.DisplayName
    $filerID = $_.FilerID
    
    ">> Updating credentials for: " + $hostname

    $filer = Get-FileServer -FileServerID $filerID
    $filer.FileWalkUsername = $newUser
    $filer.FileWalkPassword = $newPW
    $filerJob = Set-FileServer -FileServer $filer #-ForceRepair
    
}   
"----------"
# [2] Update AD walk credentials on each domain
"Updating Adwalk Credentials"
$domains = get-domainname
$domains | foreach-object {
    $domain = ""
    $domainInfo = ""
    $domainID = ""
    
    $domain = $_
    $domainInfo = Get-Domain -name $domain
    
    
    ">> Updating credentials for: " + $domain
    $domainJob = Set-Domain -Domain $domainInfo -UserCredentials $newCred

}

"----------"
# [3] Update Collector credentials on each collector
"Updating Collector Credentials"
$collectors = Get-Collector
$collectors | foreach-object {
    $collectorName = ""
    $collector = ""
    
    $collector = $_
    $collectorName = $_.DisplayName
    
    
    ">> Updating credentials for: " + $collectorName
    $collectorJob = Set-Collector -Collector $Collector -ShareCredential $newCred -InstallationCredential $installCred -Force

}
<#
# [4] Update Probe Proxy credentials
"Updating Probe Proxy Credentials"
$ProbeProxy = Get-ProbeProxy
$ProbeProxy | foreach-object {
    $ProbeProxyName = ""
    $ProbeProxy = ""
    
    $ProbeProxy = $_
    $ProbeProxyName = $_.Server

    ">> Updating credentials for: " + $ProbeProxyName
    $ProbeProxyJob = Set-ProbeProxy -Name $ProbeProxyName -VaronisCredentials $newCred 
}
#>
"----------"
"----------"
"Complete - Check Management Console for Status"
"----------"
"----------"
#Write-Host -NoNewLine 'Press any key to close...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');