Instructions for bulkAddFilers.ps1
Jonathan Thomal - jonathan@varonis.com


ChangeLog:
1/5/14
- Verified with 6.0.56 - WINDOWS only
- fixed filewalk agent reference in csv/script

12/22/14
- Verified with 6.0.55 - WINDOWS only
- Clear variables before each loop
- Added parameters in bulkAddFilers.csv to install Windows agent and Windows filewalk agent
- Added parameters in bulkAddFilers.csv to enable/disable event collection
- Added parameters in bulkAddFilers.csv to set filewalk method
- AutoFillVolumes bug is resolved; only adds top level volumes rather than all available shares **thumbs up**
- The IDU machine account is no longer required to be an admin on the remote SQL server
- enabling collect info about local accounts is enabled by default in this script


Known limitations:
- Unable to set event collection to False while adding a server
- Unable to add server using Windows credentials for database connection



Instructions:
1. Make sure you are able to execute powershell scripts. Set-ExecutionPolicy Unrestricted
2. Verify Varonis powershell module is installed on the server. This is part of the Management Console installation.
3. Fill out bulkAddFilers.csv with the info about the servers you are adding (header descriptions are below).
4. Edit bulkAddFilers.ps1. Update the "#Location of filerList.csv" value to the path where you have bulkAddFilers.csv saved (around line 5)
5. Run bulkAddFilers.ps1. I only tested this by running it in the Powershell ISE.




Column header descriptions for bulkAddFilers.csv:
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