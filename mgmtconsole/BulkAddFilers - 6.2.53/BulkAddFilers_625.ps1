#Adds file servers to Management Console queue
#
#Tested on: DatAdvantage 6.2.35, SQL 2012, Windows Server 2012r2, PowerShell 3
#
##############################################################################


####UPDATE THESE VARIABLES
$filerList = "C:\Users\jonathan\Desktop\BulkAddFilers - 6.2.35\bulkAddFilers.csv" 	#Location of filerList.csv



##############################################################################
####This stuff can be left alone

#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
"--------------------"
"--------------------"
"Importing Varonis Module"
import-module Varonis*
"Connecting to IDU"
Connect-Idu



         
$filerInfo = import-csv $filerList

$serverCount = $filerInfo.length #Used to display progress counter
$counter = 0



#Go through the filer list file and try adding each, one at a time.
$filerInfo | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    try {
        Clear-Variable -ErrorAction SilentlyContinue -name filewalkUser, 
               filewalkPW, 
               agentUser, 
               agentPW, 
               collectorUser, 
               collectorPW, 
               databaseServerUser, 
               databaseServerPW, 
               databaseUser, 
               databasePW, 
               databaseCredType, 
               hostname, 
               filerType, 
               probeID, 
               CollectLocalAccountsInfo, 
               AccessDeniedEvents, 
               OpenDirectoryAccessDeniedEvents, 
               SavePropertiesHistory, 
               OpenReadEvents, 
               FileWalkMethod, 
               SharesAutoDetectionFashion, 
               collector, 
               collectEvents,
               unixDomain,
               domain
    }
    catch {

    }
    
    #now set all the info in the CSV as variables
    #Credentials
    $filewalkUser = $_.filewalkUser              #User account used for file walk
    $filewalkPW = $_.filewalkPW
    $agentUser = $_.agentUser                    #User account with local admin rights on file server
    $agentPW = $_.agentPW
    $collectorUser = $_.collectorUser            #User account with local admin rights on collector
    $collectorPW = $_.CollectorPW
    $databaseServerUser = $_.databaseServerUser  #User account with local admin rights on SQL server
    $databaseServerPW = $_.databaseServerPW
    $databaseUser = $_.databaseUser              #User account with sysadmin rights on SQL instance. Must be a local SQL account
    $databasePW = $_.databasePW
    $databaseCredType = $_.databaseCredType      #Options: SQL, Windows

    #Other general variables
    $hostname = $_.hostname                      #hostname of filer to be added
    $filerType = $_.filerType                    #Available options: Windows, Unix
    $probeID = $_.probeID                        #There is typically only a single probe installed whose probe ID is 1
    $OpenReadEvents = 32774                      #Filter out false open events?  #Possible values: 1 = unchecked, 32774 = checked
    $collector = $_.collector                    #Hostname of Collector that will monitor the file server
    $CollectLocalAccountsInfo = $_.LocalAccountsInfo                  #Walk local accounts? $True=yes; $False=no
    $SavePropertiesHistory = $_.SaveFSPropertyHistory                 #Save file server property history?  $True=yes; $False=no
    $SharesAutoDetectionFashion = $_.autoDetectShares                 #Auto detect option in Share tab. Options: DetectMonitorAndNotify, DetectAndMonitor, DetectAndNotify, Never 
    $unixDomain = $_.unixDomain                  #name of Unix domain to associate unix filer with
    
    #install Windows agent true/false
    if ([string]::IsNullOrEmpty($_.EventAgent)) {
         $winAgent = $true #true = do not install agent
         }
         else {
             $winAgent = $false #false = install agent
             }

    #enable/disable event collection
    if ([string]::IsNullOrEmpty($_.eventCollection)) {
         $collectEvents = $false #false = do not collect events 
         }
         else {
             $collectEvents = $true #true = collect events
             }
    
    #install filewalk agent true/false
    if ([string]::IsNullOrEmpty($_.filewalkAgent)) {
         $filewalkAgent = $true #true = do not install agent
         $filewalkMethod = "NFS" #for some reason it is either VaronisWindows or NFS. Even if you want the CIFS fileWalk
         }
         else {
             $filewalkAgent = $false #false = install agent
             $filewalkMethod = "VaronisWindows"
             }

    #if a collector is specified, get the collectorID
    if ([string]::IsNullOrEmpty($collector)) {
         $collectorID = $null #no collector specified 
         }
         else {
             $collectorID = Get-Collector -name $collector
             }

    #enable/disable access denied events on files
    if ([string]::IsNullOrEmpty($_.FileAccessDeniedEvents )) {
         $AccessDeniedEvents = $false #false = do not collect events 
         }
         else {
             $AccessDeniedEvents = $true #true = collect events
             }

    #enable/disable access denied events on files
    if ([string]::IsNullOrEmpty($_.FileAccessDeniedEvents )) {
         $OpenDirectoryAccessDeniedEvents = $false #false = do not collect events 
         }
         else {
             $OpenDirectoryAccessDeniedEvents = $true #true = collect events
             }
    
    
    #increase the counter
    $counter = $counter + 1
    $progressCount = "[" + $counter + " of " + $serverCount + "] - "
    $progressCount + "Adding " + $hostname
    

    try {

        
        #test ping before trying to add the server
        if((Test-Connection -Cn $hostname -BufferSize 16 -Count 1 -ea 0 -quiet))

            #if it responds to ping, proceed
            { 
                #Here we are building out cases (ie..if the filer is windows/unix, do these steps...blah blah)
                switch ($filerType.ToLower()) 
                { 
                    "windows" {
                        
                        #Building credential objects
                        "- Building credential object"
                        $fwCred = New-Varoniscredential -username $filewalkUser -password $filewalkPW -type Windows
                        $agentCred = New-Varoniscredential -username $agentUser -password $agentPW -type Windows
                        $dbServerCred = New-Varoniscredential -username $databaseServerUser -password $databaseServerPW -type Windows
                        $dbSQLCred = New-Varoniscredential -username $databaseUser -password $databasePW -type $databaseCredType
                        
                        #this separates the collector vs non-collector situations then adds the filer
                        if ([string]::IsNullOrEmpty($collector)){ #if there is not a collector, do this
                            
                            "- Building fileserver object"
                            $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -Force –DiscoverShares TopLevelOnly
                            $filer.Config.All.SkipFileWalkChange = $SkipFileWalkChange
                            $filer.Config.All.IgnoreDriverChanges = $IgnoreDriverChanges
                            $filer.Config.All.CollectLocalAccountsInfo = $CollectLocalAccountsInfo
                            $filer.Config.All.AccessDeniedEvents = $AccessDeniedEvents
                            $filer.Config.All.OpenDirectoryAccessDeniedEvents = $OpenDirectoryAccessDeniedEvents 
                            $filer.Config.All.SavePropertiesHistory = $SavePropertiesHistory
                            $filer.Config.All.OpenReadEvents = $OpenReadEvents
                            $filer.Config.All.FileWalkMethod = $FileWalkMethod
                            $filer.Config.All.SharesAutoDetectionFashion = $SharesAutoDetectionFashion
                            $filer.CollectEvents = $collectEvents
                            #$filer.Config.All.IsFwIncEnabled = $false #uncomment to disable Incremental Filewalk
                            "- Adding fileserver to Management Console queue"
                            $jid = Add-fileserver $filer -Force
                            $progressCount + "- Added " + $hostname + " to Management Console queue"
                            }
                        else { #if there is a collector, do this
                            
                            "- Building fileserver object"
                            $collectorCred = New-Varoniscredential -username $collectorUser -password $collectorPW
                            $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -collector $collectorID -Force –DiscoverShares TopLevelOnly
                            $filer.Config.All.SkipFileWalkChange = $SkipFileWalkChange
                            $filer.Config.All.IgnoreDriverChanges = $IgnoreDriverChanges
                            $filer.Config.All.CollectLocalAccountsInfo = $CollectLocalAccountsInfo
                            $filer.Config.All.AccessDeniedEvents = $AccessDeniedEvents
                            $filer.Config.All.OpenDirectoryAccessDeniedEvents = $OpenDirectoryAccessDeniedEvents 
                            $filer.Config.All.SavePropertiesHistory = $SavePropertiesHistory
                            $filer.Config.All.OpenReadEvents = $OpenReadEvents
                            $filer.Config.All.FileWalkMethod = $FileWalkMethod
                            $filer.Config.All.SharesAutoDetectionFashion = $SharesAutoDetectionFashion
                            $filer.CollectEvents = $collectEvents
                            #$filer.Config.All.IsFwIncEnabled = $false #uncomment to disable Incremental Filewalk
                            "- Adding fileserver to Management Console queue"
                            $jid = Add-fileserver $filer -CollectorCredential $collectorCred -Force
                            $progressCount + "- Added " + $hostname + " to Management Console queue"
                            }
                        }

                     "unix" {

                        #Building credential objects
                        $fwCred = New-Varoniscredential -username $filewalkUser -password $filewalkPW -type Unix
                        $agentCred = New-Varoniscredential -username $agentUser -password $agentPW -type Unix
                        $dbServerCred = New-Varoniscredential -username $databaseServerUser -password $databaseServerPW -type Windows
                        $dbSQLCred = New-Varoniscredential -username $databaseUser -password $databasePW -type $databaseCredType
                        
                        

                        #this separates the collector vs non-collector situations then adds the filer
                        if ([string]::IsNullOrEmpty($collector)){ #if there is not a collector, do this
                            "- Building fileserver object"
                            $filer = New-UnixFileServer -name $hostname -FileWalkCredentials $fwCred -ShadowSqlCredential $dbsqlcreds -DBInstallCredential $dbServerCred -DiscoverShares TopLevelOnly
                            $filer.Config.All.SavePropertiesHistory = $SavePropertiesHistory
                            $filer.Config.All.SharesAutoDetectionFashion = $SharesAutoDetectionFashion
                            
                            #Get Unix domain info and set accordingly
                            if ($unixDomain -ne $null) {
                                $domain = Get-domain -name $unixDomain
                                $domainID = $domain.ID
                                $filer.config.UnixAffiliatedDomainId = $domainID
                            }
                            
                            "- Adding fileserver to Management Console queue"
                            $jid = Add-fileserver $filer -CollectorCredential $collectorCred -Force
                            "- Added " + $hostname + " to Management Console queue"
                            }
                        else { #if there is a collector, do this
                            "- Building fileserver object"
                            $filer = New-UnixFileServer -name $hostname -FileWalkCredentials $fwCred -ShadowSqlCredential $dbsqlcreds -DBInstallCredential $dbServerCred -DiscoverShares TopLevelOnly -Collector $collectorID
                            $filer.Config.All.SavePropertiesHistory = $SavePropertiesHistory
                            $filer.Config.All.SharesAutoDetectionFashion = $SharesAutoDetectionFashion
                            
                            #Get Unix domain info and set accordingly
                            if ($unixDomain -ne $null) {
                                $domain = Get-domain -name $unixDomain
                                $domainID = $domain.ID
                                $filer.config.UnixAffiliatedDomainId = $domainID
                            }

                            "- Adding fileserver to Management Console queue"
                            $jid = Add-fileserver $filer -CollectorCredential $collectorCred -Force
                            "- Added " + $hostname + " to Management Console queue"
                            }
                        }

            

                }
            }
        
        #if it doesnt respond, output the hostname and ping status
        else { 
        "** " + $hostname + " - NOT RESPONDING TO PING **"
        }
    }

    catch {

        $_.Exception.Message



    }
    
}







"--------------------"

#disconnect from IDU
#"Disconnecting from IDU"
#disconnect-idu

"Complete - Check the Management Console for file server status"