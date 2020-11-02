Instructions for bulkAddFilers.ps1

################ 
Instructions   #
################
1. Make sure you are able to execute powershell scripts. Set-ExecutionPolicy Unrestricted
2. Verify Varonis PowerShell module is installed on the server. This is part of the Management Console installation.
3. Fill out bulkAddFilers.csv with the info about the servers you are adding (header descriptions are below).
4. Edit bulkAddFilers.ps1. Update the "#Location of filerList.csv" value to the path where you have bulkAddFilers.csv saved (around line 5)
5. Run bulkAddFilers.ps1. "./bulkaddfilers.ps1" in command line.


##########################
Current Default Settings #
##########################
- Filter out false open events
- Only monitor top level shares


####################
Known limitations  #
####################
- Unable to set event collection to False while adding a server (even if you're not installing the agent).The "Collect Events" checkbox will remain checked after adding a server. After the servers are added, select all > right-click > Do not collect events*
- *Prior to 6.2.35* Unable to add server using Windows credentials for database connection 
- The server counter display does not work if there is only one line item in the CSV file
- Only supports adding Windows servers


###################################################
!!! DON'T MESS WITH THE HEADERS !!!               #
                                                  #
Column header descriptions for bulkAddFilers.csv: #
###################################################
filerType 			- case sensitive. possible options are: windows, emc 
hostname 			- hostname of the file server to be monitored. May need to be fully qualified depending on network/DNS/etc
filewalkUser 			- domain account that will perform the filewalk
filewalkPW 			- password of the domain account that will perform the filewalk
agentUser 			- domain account that will install the Varonis agent 
agentPW 			- password of the domain account that will install the Varonis agent 
databaseServerUser 		- domain account that is a local admin on the SQL server 
databaseServerPW 		- password of domain account that is a local admin on the SQL server 
databaseUser 			- user account with sysadmin privileges on the SQL instance
databasePW 			- password for the user account with sysadmin privileges on the SQL instance
databaseCredType 		- Options: "SQL" or "Windows" - type of credentials being used local SQL or domain user
probeID 			- ID of the probe that will be monitoring the filer. Can be found in the probes table of vrnsdomainDB; Typically 1
collector 			- hostname of the collector that will monitor the file server. May need to be fully qualified depending on network/DNS/etc
collectorUser 			- domain account that will install the Varonis services on collector
CollectorPW 			- password of the domain account that will install the Varonis services on collector
EventAgent 			- WINDOWS ONLY - put an 'X' in the column to install the agent
*EventCollection 		- *Does not work as of 6.2.35.  - put an 'X' in the column to enable event collection
FilewalkAgent 			- WINDOWS ONLY - put an 'X' in the column to install the agent
FilewalkMethod 			- Options: "Varonis" or "CIFS"
autoDetectShares 		- Options: DetectMonitorAndNotify, DetectAndMonitor, DetectAndNotify, Never 
LocalAccountsInfo 		- put an 'X' in the column to collect local account info
FileAccessDeniedEvents 		- WINDOWS ONLY - put an 'X' in the column to collect access denied events on files
FolderAccessDeniedEvents 	- WINDOWS ONLY - put an 'X' in the column to collect access denied events on folders. FileAccessDeniedEvents MUST be enabled too
SaveFSPropertyHistory 		- put an 'X' in the column to save file server property history



############
ChangeLog  #
############

5/23/16
- Verified with 5.9.76 - WINDOWS only
