Instructions for bulkChangeFWCreds.ps1
Jonathan Thomal - 1/15/14 - Jonathan@varonis.com


Instructions:

1. Make sure you are able to execute powershell scripts. You can run Disable-PS-Security.bat to modify the execution policy on the server.
2. Verify Varonis powershell module is installed on the server. This is part of the Management Console installation.
3. Fill out bulkChangeFWCreds.csv with the info about the servers you are adding (header descriptions are below).
4. Edit bulkChangeFWCreds.ps1. Change the value on line 2 for the $filerList variable to the path where you have bulkChangeFWCreds.csv saved.
5. Run bulkChangeFWCreds.ps1. I only tested this by running it in the Powershell ISE.