Instructions for bulkAddFilers.ps1

################ 
Instructions   #
################
Prerequisites:
- PowerShell 3
---------------
1. Make sure you are able to execute powershell scripts. Set-ExecutionPolicy Unrestricted
2. Verify Varonis PowerShell module is installed on the server. This is part of the Management Console installation.
3. Fill out bulkAddFilers.csv with the info about the servers you are adding (header descriptions are below).
4. Edit bulkAddFilers_[x].ps1. Update the "#Location of filerList.csv" value to the path where you have bulkAddFilers.csv saved (around line 5)
5. Run bulkAddFilers_[x].ps1


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
- If a Unix server is not supported, you will see a "Complete with error" indicator in the Management Console. The error will indicate the agent was not installed and event collection was disabled. The filewalk method is still "Varonis" and will need to be changed to "NFS". Bug#450559, Expected fix: 6.2.50



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
unixDomain			- UNIX ONLY - Enter affiliated Unix domain. Domain must be defined in the Domain section of the Management Console


############
ChangeLog  #
############
7/12/16
- Updated share discovery for Windows

6/1/16
- Added ability to define Unix Domain for Unix servers

5/2/16
- Verified with 6.2.35 - Windows and Unix. From my testing it appears backward compatible with 6.0.112
- Added columns to csv for AutoDetectShares, LocalAccountsInfo, FileAccessDeniedEvents, FolderAccessDeniedEvents, and SaveFSPropertyHistory
- removed several default settings and moved them to be options in the csv template

6/3/15
- Verified with 6.0.90 - WINDOWS only
- updated script to accommodate the new syntax for discovering top level shares; -AutoFillVolumes is deprecated as of 6.0.85

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

