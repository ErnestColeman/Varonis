#Jonathan Thomal - 7/29/14 - jonathan@varonis.com
#Tested on: DatAdvantage 6.0.55, SQL 2012, Windows Server 2008r2, PowerShell 3

####UPDATE THESE VALUES
#Location of filerList.csv
$filerList = "C:\bulkAddFilers\bulkAddFilers.csv"





####YOU SHOULDN'T HAVE TO UPDATE THIS SECTION
#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

#Import-Module -Name 'VaronisManagement'
"Importing Varonis Module"
import-module Varonis*
"Connecting to IDU"
Connect-Idu
#for loop that adds the servers in the list.
$counter = 0
$filerInfo = import-csv $filerList
$filerInfo | foreach-object {
    "--------------------"
    #clear variables before each loop
    Clear-variable -Name filerType
    Clear-variable -Name hostname
    Clear-variable -Name filewalkUser
    Clear-variable -Name filewalkPW
    Clear-variable -Name agentUser
    Clear-variable -Name agentPW
    Clear-variable -Name databaseServerUser
    Clear-variable -Name databaseServerPW
    Clear-variable -Name probeID
    Clear-variable -Name collectorID
    Clear-variable -Name collectorUser
    Clear-variable -Name collectorPW
    Clear-variable -Name method
    Clear-variable -Name winAgent
    Clear-variable -Name collectEvents
    Clear-variable -Name filewalkAgent
    Clear-variable -Name filewalkMethod
    


    #general variables from csv
    $filerType = $_.filerType.toLower()
    $hostname = $_.hostname
    $filewalkUser = $_.filewalkUser
    $filewalkPW = $_.filewalkPW
    $agentUser = $_.agentUser   
    $agentPW = $_.agentPW
    $databaseServerUser = $_.databaseServerUser
    $databaseServerPW = $_.databaseServerPW     
    $databaseUser = $_.databaseUser
    $databasePW = $_.databasePW
    $probeID = $_.probeID   
    $collectorID = Get-Collector -name $_.collector
    $collector = $_.collector
    $collectorUser = $_.collectorUser
    $collectorPW = $_.collectorPW
    
    #install Windows agent true/false
    if ([string]::IsNullOrEmpty($_.winAgent)) {
         $winAgent = $true #true = do not install agent
         }
         else {
             $winAgent = $false #false = install agent
             }

    <# this doesn't work in 6.0.55
    #enable/disable event collection
    if ([string]::IsNullOrEmpty($_.eventCollection)) {
         $collectEvents = $false #false = do not collect events 
         }
         else {
             $collectEvents = $true #true = collect events
             }
    #>

    #install filewalk agent true/false
    if ([string]::IsNullOrEmpty($_.filewalkAgent)) {
         $filewalkAgent = $true #true = do not install agent
         }
         else {
             $filewalkAgent = $false #false = install agent
             }

    #set filewalk method
    if ($_.filewalkMethod = "Varonis") {
        $filewalkMethod = "VaronisWindows"
        }
        else {
            $filewalkMethod = "NFS" #for some reason it is either VaronisWindows or NFS. Even if you want the CIFS fileWalk
            } 

   
    
    #EMC specific variables
    $method = $_.EMCEventCollection

    $serverCount = $hostname.count
    $counter = $counter + 1

    
    #test ping before trying to add the server
    if((Test-Connection -Cn $hostname -BufferSize 16 -Count 1 -ea 0 -quiet))

        #if it responds to ping, proceed
        { 
            #Here we are building out cases (ie..if the filer is windows, do these steps...blah blah)
            switch ($filerType) 
            { 
                "windows" {
                    #just getting some vars ready for the actual command
                    "[" + $counter + " of " + $serverCount + "]" + " - " +  "Adding " + $hostname + " to MC queue"
                    $fwCred = New-Varoniscredential -username $filewalkUser -password $filewalkPW -type Windows
                    $agentCred = New-Varoniscredential -username $agentUser -password $agentPW -type Windows
                    $dbServerCred = New-Varoniscredential -username $databaseServerUser -password $databaseServerPW
                    $dbSQLCred = New-Varoniscredential -username $databaseUser -password $databasePW -type Sql
                
                    #this separates the collector vs non-collector situations then adds the filer
                    if ([string]::IsNullOrEmpty($collector)){ #if there is not a collector, do this
                        $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID
                        $filer.Config.SkipFileWalkChange = $filewalkAgent #install filewalk agent?
                        $filer.Config.IgnoreDriverChanges = $winAgent #install winAgent?
                        $filer.Config.All.CollectLocalAccountsInfo = $true
                        $filer.Config.All.AccessDeniedEvents = $true
                        $filer.Config.All.OpenDirectoryAccessDeniedEvents = $true
                        $filer.Config.All.SavePropertiesHistory = $true
                        $filer.Config.All.OpenReadEvents = 32774 #possible values: 1 = unchecked, 32774 = checked
                        $filer.Config.All.FileWalkMethod = $filewalkMethod
                        #$filer.Config.All.IsFwIncEnabled = $false #uncomment to disable Incremental Filewalk
                        Add-fileserver $filer -AutoFillVolumes -Force
                        }
                    else { #if there is a collector, do this
                        $collectorCred = New-Varoniscredential -username $collectorUser -password $collectorPW
                        $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -collector $collectorID
                        $filer.Config.SkipFileWalkChange = $filewalkAgent #install filewalk agent?
                        $filer.Config.IgnoreDriverChanges = $winAgent #install winAgent?
                        $filer.Config.All.CollectLocalAccountsInfo = $true
                        $filer.Config.All.AccessDeniedEvents = $true
                        $filer.Config.All.OpenDirectoryAccessDeniedEvents = $true
                        $filer.Config.All.SavePropertiesHistory = $true
                        $filer.Config.All.OpenReadEvents = 32774 #possible values: 1 = unchecked, 32774 = checked
                        $filer.Config.All.FileWalkMethod = $filewalkMethod
                        #$filer.Config.All.IsFwIncEnabled = $false #uncomment to disable Incremental Filewalk
                        Add-fileserver $filer -AutoFillVolumes -CollectorCredential $collectorCred -Force
                        }
                    }

            # !!! this needs to be updated and verified for 6.0.x !!!
                <# 
                "emc" {
                    #just getting some vars ready for the actual command
                    "Adding " + $hostname
                    $fwCred = New-Varoniscredential -username $filewalkUser -password $filewalkPW                 
                    $agentCred = New-Varoniscredential -username $agentUser -password $agentPW
                    $dbServerCred = New-Varoniscredential -username $databaseServerUser -password $databaseServerPW
                    $dbSQLCred = New-Varoniscredential -username $databaseUser -password $databasePW
                    #this separates the collector vs non-collector situations then adds the filer
                    if ([string]::IsNullOrEmpty($collector)){
                        $filer = New-CelerraFileServer -method $method -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID
                        Add-fileserver $filer -AutoFillVolumes 
                        }
                    else {
                        $collectorCred = New-Varoniscredential -username $collectorUser -password $collectorPW
                        $filer = New-CelerraFileServer -method $method -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -collector $collectorID
                        Add-fileserver $filer -AutoFillVolumes  -CollectorCredential $collectorCred
                        }
                    } 
                "netapp" {
                    #just getting some vars ready for the actual command
                    "Adding " + $hostname
                    $fwCred = New-Varoniscredential -username $filewalkUser -password $filewalkPW                 
                    #$collectorCred = New-Varoniscredential -username $collectorUser -password $collectorPW
                    $dbServerCred = New-Varoniscredential -username $databaseServerUser -password $databaseServerPW
                    $dbSQLCred = New-Varoniscredential -username $databaseUser -password $databasePW
                    #this separates the collector vs non-collector situations then adds the filer
                    if ([string]::IsNullOrEmpty($collector)){
                        $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID
                        Add-fileserver $filer -AutoFillVolumes 
                        }
                    else {
                        $collectorCred = New-Varoniscredential -username $collectorUser -password $collectorPW
                        $filer = New-NetAppFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -collector $collectorID
                        Add-fileserver $filer -AutoFillVolumes  -CollectorCredential $collectorCred
                        }
                    }
                    #>

            }
        }
     #if it doesnt respond, just output the hostname and ping status
      else { 
      "** " + $hostname + " - NOT RESPONDING TO PING **"
      
     


     }
     "--------------------"
}
#disconnect from IDU
#"Disconnecting from IDU"
#disconnect-idu

"Complete - Check the Management Console for file server status"