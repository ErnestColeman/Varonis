<#
.SYNOPSIS
    Script to check whether dataprivilege is reachable
.DESCRIPTION
    This scipt is to check connecitivty of dataprivilege. 
    This can be run from any workstation/server that has SSMS installed.
.NOTES
    File Name      : dataprivilegeUrl_Check.ps1
    Author         : Ernest Coleman (ecoleman@varonis.com)
    Prerequisite   : Powershell 4 and up, SSMS installed on server executing script, and logged in as VaronisServiceAccount
#>

#SQL Query for getting the URL for DP
$Query = @"
SELECT [Value] FROM [dbo].[KeyValue] WHERE [Key] = 'ApplicationPath'
"@

$SQL = $env:COMPUTERNAME | Foreach-Object {Get-ChildItem -Path "SQLSERVER:\SQL\$_"}

foreach($s in $SQL){
#Running Query against SQL server\Instance. Update ECHOSQL\ECHO7X to customer ServerInstance
$DSP = Invoke-SqlCmd -ServerInstance $s -Database Vrnsdomaindb -Query $Query | Select-Object -ExpandProperty value
#Prints the Output to the PS Window
$DSP

#Tests if we have access to DP
Invoke-WebRequest -Uri "$DSP" -UseDefaultCredentials | Select-Object StatusDescription
}