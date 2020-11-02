<#Update Varonis Credentials
- Filewalk
- AD Walk
- Collectors
- Probe proxies

Verified on DA v6.0.112; pre-6.0.112 requires patch 377395 in order to set collector credentials

This does NOT update the SQL credentials stored under Root > Security tab. You must update them manually.


#>

#AD Walk credentials. If there are more than two monitored domains, the script must be updated accordingly 
$domain1 = "jt.com" #UPDATE THIS LINE
$newD1User = "jt\varonis" #UPDATE THIS LINE
$newD1Pw = "password1" #UPDATE THIS LINE
 
$domain2 = "jt2.com" #UPDATE THIS LINE
$newD2User = "jt2\varonis2" #UPDATE THIS LINE
$newD2Pw = "password1" #UPDATE THIS LINE

#File walk, Collector working share, probe proxy working credentials
$newUser = "jt\nithil" #UPDATE THIS LINE
$newPW = "password1" #UPDATE THIS LINE

#Collector host credential (must be a LOCAL ADMIN with LOG ON RIGHTS on ALL collectors)
$admColUser = "jt\jonathan" #UPDATE THIS LINE
$admColPW = "password1" #UPDATE THIS LINE



#connect to IDU
Import-Module VaronisManagement
">> Connecting to IDU.."
Connect-IDU

$newD1Cred = New-VaronisCredential -username $newD1User -password $newD1Pw
$newD2Cred = New-VaronisCredential -username $newD2User -password $newD2Pw
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
    
    $domain = $_
    #echo " - working on $domain"
    #echo " - setting creds to 
    $domainInfo = Get-Domain -name $domain
    
    
    ">> Updating credentials for: " + $domain

    if ($domain -eq $domain1) {
        echo " - 1. $domain equals $domain1"
        echo " - 1. setting creds on $domain"
        $domain1Job = Set-Domain -Domain $domainInfo -UserCredentials $newD1Cred
    }
    elseif ($domain -eq $domain2) {
        echo " - 2. $domain equals $domain2"
        echo " - 2. setting creds on $domain"
        $domain2Job = Set-Domain -Domain $domainInfo -UserCredentials $newD2Cred
    }

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