<#
.SYNOPSIS
    Update Varonis Credentials for Filers, Domains, and Collectors
.DESCRIPTION
    This scipt is to check connecitivty of dataprivilege. 
    This can be run from any workstation/server that has SSMS installed.
.NOTES
    File Name      : dataprivilegeUrl_Check.ps1
    Author         : Ernest Coleman (ecoleman@varonis.com)
    Prerequisite   : Powershell 4 and up, SSMS installed on server executing script, and logged in as VaronisServiceAccount
#>

# Update Varonis Credentials
# - Filewalk
# - AD Walk
# - Collectors
#
# Tested on DA versions 6.0.112 and 6.2.35; pre-6.0.110 requires patch 377395 in order to set collector credentials
#
# Instructions:
# 1. This script imports a csv file with the following headers:  Component,Hostname,Username,Password
# 2. Possible "Component" values: adwalk, collector, fileserver
# 3. "Hostname" values should match what is defined in the Management Console under each category

$credList = "C:\Users\jonathan\Desktop\updateVaronisCredentials\credChange.csv" #path to csv file with updated credentials


Import-Module VaronisManagement
$connect = Connect-IDU

$creds = import-csv $credList
$totalItems = $creds | Measure-Object | Select-Object -expand count

$startTime = get-date -DisplayHint DateTime


"Total credentials to update: " + $totalItems
"Start time: " + $startTime
$counter = 0

"----------"

$creds | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    Clear-Variable -name Component,Hostname,Username,Password,newCred,filer,filerID,domainInfo,collector



    
    #now set all the info in the CSV as variables
    $Component = $_.Component
    $hostname = $_.Hostname
    $Username = $_.Username
    $Password = $_.Password


    #create credential object
    $newCred = New-VaronisCredential -username $Username -password $Password

    #Here we are building out cases (ie..if the component is adwalk/collector/fileserver, do these steps..)
    switch ($component.ToLower()) 
    { 
        "adwalk" {
        #Update adwalk credentials on specified domain
        
        "Updating Adwalk credentials for: " + $hostname
        $domainInfo = Get-Domain -name $hostname
        $domainJob = Set-Domain -Domain $domainInfo -UserCredentials $newCred
        }

        "collector" {
        #Update collect credentials on specified collector
        "Updating Collector credentials for: " + $hostname
        $collector = Get-Collector -Name $hostname
        $collectorJob = Set-Collector -Collector $collector -ShareCredential $newCred -InstallationCredential $newCred -Force
        }

        "fileserver" {
        #Update filewalk credentials on specified file server
        "Updating Filewalk Credentials on: " + $hostname
        $filer = Get-FileServer -Name $hostname
        $filerID = $filer.filerID
        $filer.FileWalkUsername = $Username
        $filer.FileWalkPassword = $Password
        $filerJob = Set-FileServer -FileServer $filer #-ForceRepair
        }
        
    }
}






























<#


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
    $collectorJob = Set-Collector -Collector $Collector -ShareCredential $newCred -InstallationCredential $newCred -Force

}
"----------"
"----------"
"Complete - Check Management Console for Status"
"----------"
"----------"
Write-Host -NoNewLine 'Press any key to close...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

#>