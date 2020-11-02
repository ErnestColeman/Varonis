<#
.SYNOPSIS
    Script for collecting Varonis Event logs from all hosts
.DESCRIPTION
    A detailed description of the function or script. This keyword can be
    used only once in each topic.
.NOTES
    File Name      : Collect-Logs.ps1
    Author         : Tim Frasier (TFrasier@varonis.com)
    Prerequisite   : PowerShell V2
    Copyright 2017 - Tim Frasier
#>

#Create Varonis_Logs folder on the root of C:
New-Item -Path C:\Varonis_Logs -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Read Hostname into $local variable
$local = Hostname

#Import Varonis Module
Import-Module VaronisManagement -ErrorAction Stop

#Connect to IDU
Connect-IDU

######Process SQL######

#Create SQL Folder
New-Item -Path C:\Varonis_Logs\SQL -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Create Version.txt
BCP "SELECT @@Version" queryout C:\Varonis_Logs\SQL.txt -c -T

######Process IDU######

#Create IDU Folder
New-Item -Path C:\Varonis_Logs\IDU -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Create IDU.txt
BCP "SELECT HostName FROM VrnsDomainDB.dbo.vwenvi_featuresview where cName = 'IDU Server'" queryout IDU.txt -c -T

#Read in list of hosts from Filers.txt
$idus = Get-Content IDU.txt

#ForEach loop to go through each Filer in Filers.txt and retrieve the Varonis log from each
ForEach ($idu in $idus) {
    #Delete previous exported logs from root of C:
    Remove-Item  \\$idu\C$\$idu.evtx -ErrorAction SilentlyContinue
    #Export Varonis Log
    wevtutil epl Varonis C:\$idu.evtx /r:$idu
    #Move newly exported Varonis log from the machine it was exported from to the IDU
    Move-Item -Path \\$idu\C$\$idu.evtx -Destination \\$local\C$\Varonis_Logs\IDU\$idu.evtx -Force
    #Increase max size of the Varonis Log to 64 MB
    Limit-EventLog -LogName Varonis -ComputerName $idu -MaximumSize 65536
    #Export Varonis Log
    wevtutil epl Commit C:\$idu'Commit'.evtx /r:$idu
    #Move newly exported Commit log from the machine it was exported from to the IDU
    Move-Item -Path \\$idu\C$\$idu'Commit'.evtx -Destination \\$local\C$\Varonis_Logs\IDU\$idu.evtx -Force
}

Write-Output 'Done with IDU!'

######Process Collectors######

#Create Collectors Folder
New-Item -Path C:\Varonis_Logs\Collectors -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Create Collectors.txt
BCP "SELECT Hostname FROM VrnsDomainDB.dbo.vwenvi_featuresview WHERE cName = 'Collector Service' AND cIsDeleted = 0" queryout Collectors.txt -c -T

#Read in list of hosts from Filers.txt
$collectors = Get-Content Collectors.txt

#ForEach loop to go through each Filer in Filers.txt and retrieve the Varonis log from each
ForEach ($collector in $collectors) {
    #Delete previous exported logs from root of C:
    Remove-Item  \\$collector\C$\$collector.evtx -ErrorAction SilentlyContinue
    #Export Varonis Log
    wevtutil epl Varonis C:\$collector.evtx /r:$collector
    #Move newly exported Varonis log from the machine it was exported from to the IDU
    Move-Item -Path \\$collector\C$\$collector.evtx -Destination \\$local\C$\Varonis_Logs\Collectors\$collector.evtx -Force
}

Write-Output 'Done with Collectors!'

######Process Filers######

#Create Filers Folder
New-Item -Path C:\Varonis_Logs\Filers -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Create Filers.txt
BCP "SELECT Hostname FROM VrnsDomainDB.dbo.vwenvi_featuresview WHERE cName = 'File Server' AND cIsDeleted = 0 AND Hostname IS NOT NULL' AND filer_Monitored = 1" queryout Filers.txt -c -T

#Read in list of hosts from Filers.txt
$filers = Get-Content Filers.txt

#ForEach loop to go through each Filer in Filers.txt and retrieve the Varonis log from each
ForEach ($filer in $filers) {
    #Delete previous exported logs from root of C:
    Remove-Item  \\$filer\C$\$filer.evtx -ErrorAction SilentlyContinue
    #Export Varonis Log
    wevtutil epl Varonis C:\$filer.evtx /r:$filer
    #Move newly exported Varonis log from the machine it was exported from to the IDU
    Move-Item -Path \\$filer\C$\$filer.evtx -Destination \\$local\C$\Varonis_Logs\Filers\$filer.evtx -Force
}

Write-Output 'Done with Filers!'

######Process Probes######

#Create Probes Folder
New-Item -Path C:\Varonis_Logs\Probes -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#Create Probes.txt
BCP "SELECT Hostname FROM VrnsDomainDB.dbo.vwenvi_featuresview WHERE cName = 'Probe Service' AND cIsDeleted = 0" queryout Probes.txt -c -T

#Read in list of hosts from Collectors.txt
$probes = Get-Content Probes.txt

#ForEach loop to go through each Filer in Filers.txt and retrieve the Varonis log from each
ForEach ($probe in $probes) {
    #Delete previous exported logs from root of C:
    Remove-Item  \\$probe\C$\$probe.evtx -ErrorAction SilentlyContinue
    #Export Varonis Log
    wevtutil epl Varonis C:\$probe.evtx /r:$probe
    #Move newly exported Varonis log from the machine it was exported from to the IDU
    Move-Item -Path \\$probe\C$\$probe.evtx -Destination \\$local\C$\Varonis_Logs\Probes\$probe.evtx -Force
}

######Increase Log Size######

#Increase IDU Commit Log Max Size to 64 MB
ForEach ($idu in $idus) {
    Limit-EventLog -LogName Commit -ComputerName $idu -MaximumSize 65536
}

#Increase IDU Varonis Log Max Size to 64 MB
ForEach ($idu in $idus) {
    Limit-EventLog -LogName Varonis -ComputerName $idu -MaximumSize 65536
}

#Increase Collector Varonis Log Max Size to 64 MB
ForEach ($collector in $collectors) {
    Limit-EventLog -LogName Varonis -ComputerName $collector -MaximumSize 65536
}

#Increase Filer Varonis Log Max Size to 64 M
ForEach ($filer in $filers) {
    Limit-EventLog -LogName Varonis -ComputerName $filer -MaximumSize 65536
}

#Increase Probe Varonis Log Max Size to 64 MB
ForEach ($probe in $probes) {
    Limit-EventLog -LogName Varonis -ComputerName $probe -MaximumSize 65536
}

######Cleanup######

#Delete IDUs.txt
Remove-Item  IDUs.txt -ErrorAction SilentlyContinue

#Delete Collectors.txt
Remove-Item  Collectors.txt -ErrorAction SilentlyContinue

#Delete Filers.txt
Remove-Item  Filers.txt -ErrorAction SilentlyContinue

#Delete Probes.txt
Remove-Item  Probes.txt -ErrorAction SilentlyContinue

######Finished######

Write-Output 'Done with Probes!'

Write-Output 'ALL DONE!'