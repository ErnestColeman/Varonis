Instructions for bulkAddFilers.ps1
Jonathan Thomal - jonathan@varonis.com


############
ChangeLog: #
############
6/23/15
- I think I fixed the counter

6/3/15
- Verified with 6.0.90 - WINDOWS only
- updated script to accommodate the new syntax for discovering top level shares; -AutoFillVolumes is deprecated as of 6.0.85
- added "Current Default Settings" below. The other settings should be configurable via csv file


6/2/15
- Added disclaimer in README file to not mess with the headers. Don't move them, rename them, change their colors/fonts, look at them, talk to them, buy them presents, take them to dinner, etc. 
- But what if the header swiped right on Tinder? <- unmatch them
- Changed access denied event collection = $false to match default behavior
- Starting from version 6.0.85, we have changed the way the shares added, this is due to another customer request (GSK), who insisted of adding all shares and not just top level. So by default we add everything as it was in earlier versions to preserve backward compatibility and added a new parameter to all New-*FileServer cmdleds named DiscoverShares with options: None, TopLevelOnly and All, like this:
New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID –Force –DiscoverShares “TopLevelOnly”

 
1/5/14
- Verified with 6.0.56 - WINDOWS only
- fixed filewalk agent reference in csv/script

12/22/14
- Verified with 6.0.55 - WINDOWS only
- Clear variables before each loop
- Added parameters in bulkAddFilers.csv to install Windows agent and Windows filewalk agent
- Added parameters in bulkAddFilers.csv to enable/disable event collection - this doesn't actually do anything. Not supported by Varonis PowerShell yet.
- Added parameters in bulkAddFilers.csv to set filewalk method
- AutoFillVolumes bug is resolved; only adds top level volumes rather than all available shares **thumbs up**
- The IDU machine account is no longer required to be an admin on the remote SQL server
- enabling collect info about local accounts is enabled by default in this script




####################
Known limitations: #
####################
- Unable to set event collection to False while adding a server
- Unable to add server using Windows credentials for database connection
- On version 6.0.90, all shares on windows servers were selected instead of volumes - RESOLVED with new "–DiscoverShares TopLevelOnly" switch


################
Instructions:  #
################
1. Make sure you are able to execute powershell scripts. Set-ExecutionPolicy Unrestricted
2. Verify Varonis powershell module is installed on the server. This is part of the Management Console installation.
3. Fill out bulkAddFilers.csv with the info about the servers you are adding (header descriptions are below).
4. Edit bulkAddFilers.ps1. Update the "#Location of filerList.csv" value to the path where you have bulkAddFilers.csv saved (around line 5)
5. Run bulkAddFilers.ps1. "./bulkaddfilers.ps1" in command line. I only tested this by running it in the Powershell ISE.


##########################
Current Default Settings #
##########################
- Only monitor top-level shares (C$, D$, etc..)
- Collect local account info
- Save file server property history
- Filter out false open events




###################################################
!!! DON'T MESS WITH THE HEADERS !!!               #
                                                  #
Column header descriptions for bulkAddFilers.csV: #
###################################################
filerType - case sensitive. possible options are: windows, emc 
hostname - hostname of the file server to be monitored. May need to be fully qualified depending on network/DNS/etc
filewalkUser - domain account that will perform the filewalk
filewalkPW - password of the domain account that will perform the filewalk
agentUser - domain account that will install the Varonis agent 
agentPW - password of the domain account that will install the Varonis agent 
databaseServerUser - domain account that is a local admin on the SQL server 
databaseServerPW - password of domain account that is a local admin on the SQL server 
databaseUser - user account with sysadmin privileges on the SQL instance
databasePW - password for the user account with sysadmin privileges on the SQL instance
databaseCredType - Options: "SQL" or "Windows" - type of credentials being used local SQL or domain user
probeID - ID of the probe that will be monitoring the filer. Can be found in the probes table of vrnsdomainDB
collector - hostname of the collector that will monitor the file server. May need to be fully qualified depending on network/DNS/etc
collectorUser - domain account that will install the Varonis services on collector
CollectorPW - password of the domain account that will install the Varonis services on collector
WinAgent - WINDOWS ONLY - put an 'X' in the column to install the agent
EventCollection - *This does not work as of 6.0.56* - put an 'X' in the column to enable event collection
FilewalkAgent - WINDOWS ONLY - put an 'X' in the column to install the agent
FilewalkMethod - Options: "Varonis" or "CIFS"
EMCEventCollection - EMC only, case sensitive. 'cepa' is the only option I tested