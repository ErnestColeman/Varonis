#Group Policy Version Checker

$startpath = get-location | Select-Object path
$startpath = $startpath.path

import-module activedirectory
$hostnames = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Filter * -Server $_ } | Select-Object hostname
$domain = (get-adforest).rootdomain
$myArray = @()
$serverList = @()
$hostnames = $hostnames.hostname
$count = 0

foreach ($srv in $hostnames) {
    $ping = Test-NetConnection $srv | Select-Object PingSucceeded
    $ping = $ping.pingsucceeded
    if ($ping -like "true") {
        write-host $srv "reply from host successful"
        $serverlist += [string]$srv
    }
}

foreach ($server in $serverList) {
          
    $path = "\\" + $server + "\sysvol\" + $domain + "\Policies\"
    #write-host $path
         
    set-location $path
    $folders = get-childitem -directory
         
    foreach ($folder in $folders) {
           
        #write-host $folder.name
        $subfolder = $folder.name
        $subpath = $path + $subfolder
           
           
        $pathcheck = test-path $subpath
           
        if ($pathcheck -eq $true) {
           
            set-location $subpath
            
            $filecheck = test-path GPT.INI
            
            if ($filecheck -eq $true) {
                $version = get-content GPT.INI | select-string "Version"
                $version = $version -split "="
                $version = $version[1]
                $PSO = New-Object PSObject -property @{Server = $server; Folder = $subfolder; Version = $version }
                $myArray += $PSO
            }
        }
    }
}
         
$myArray | Sort-Object -Property Folder
#Grab Unique GPO Objects:
$folderchk = $myArray | Select-Object folder
$folderchk = $folderchk.folder
$folderchk = $folderchk | Select-Object -uniq

#Create array to track version numbers in loop
$myversions = @()

#Loop through myarray and assign each version number to myversions
foreach ($gpo in $folderchk) {
         
    foreach ($row in $myArray) {

        if ($row.folder -like $gpo) {
            $myversions += $row.version
        }
    } 
    $checkveruni = $myversions | Select-Object -uniq
    $checkveruni = $checkveruni.count  
    if ($checkveruni -gt 1) {
        write-host "Mismatch found in $row"
        $count++
    }
    else {
        #write-host "Versions Match for:" $gpo
    }
    $myversions = $null
} 

set-location $startpath
start-sleep -seconds 2
if ($count -eq 0) { write-host "Congratualtions all GPO versions are in sync in your domain!" } 