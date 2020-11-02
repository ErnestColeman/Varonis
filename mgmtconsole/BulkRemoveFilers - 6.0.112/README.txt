Instructions for bulkRemoveFilers.ps1

################ 
Instructions   #
################
1. Make sure you are able to execute powershell scripts. Set-ExecutionPolicy Unrestricted
2. Verify Varonis PowerShell module is installed on the server. This is part of the Management Console installation.
3. Fill out filersToRemove.csv with the info about the servers you are removing (header descriptions are below).
4. Edit bulkRemoveFilers.ps1. Update the "#Location of filerList.csv" value to the path where you have filersToRemove.csv saved
5. Run bulkRemoveFilers.ps1


####################
Known limitations  #
####################



####################################################
!!! DON'T MESS WITH THE HEADERS !!!                #
                                                   #
Column header descriptions for filersToRemove.csv: #
####################################################
hostname 			- hostname of the file server as it is defined in the Management Console
filerType 			- case sensitive. Options: windows, unix
RemoveAgent 			- put an 'X' in the column to attempt removal of Varonis agent
agentUser 			- domain account that will install the Varonis agent 
agentPW 			- password of the domain account that will install the Varonis agent 


############
ChangeLog  #
############

5/5/2016
- Script created. Tested on 6.0.112 and 6.2.35