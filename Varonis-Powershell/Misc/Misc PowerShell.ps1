#Example code for encoding the RabbitMQ guest/guest creds and accessing the API

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "guest","guest")))

Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri "http://localhost:15672/api/shovels"

#----------------------------------------

#Code to retrieve the Role (IDU,Collector,???) from the Registry

$ServerRole = (Get-ItemProperty -Path 'HKLM:\Software\Varonis\IDU Server\').Role
Write-Host $ServerRole

#----------------------------------------

#Example code for running SQL queries against VrnsDomainDB via PowerShell

Invoke-Sqlcmd -Query "USE VrnsDomainDB SELECT * From KeyValue" | Export-Csv C:\Temp\Result.csv
Invoke-Sqlcmd -Query "USE VrnsDomainDB SELECT * From KeyValue" | OUt-Gridview

#----------------------------------------

#Example code mounting a SQL instance as a file system

Import-Module SqlServer
Set-Location "SQLSERVER:\SQL\CharlieSQL\Charlie64"
Get-ChildItem Databases | Where-Object -Property RecoveryModel -eq 'Full'

#----------------------------------------

Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Varonis\Publisher -Name Salad

Get-ItemProperty HKLM:\SOFTWARE\Varonis\Publisher

Get-EventLog -LogName Security -ComputerName $dc -UserName $serviceaccount

#----------------------------------------

#Example code for setting all GPOs to allow a certain User and Computer read access.

Set-GPPermission -All -PermissionLevel GpoRead -TargetType User -TargetName "KPCHRRAD\svc_Varonis" -DomainName KPCHRRAD
Set-GPPermission -All -PermissionLevel GpoRead -TargetType Computer -TargetName Mink2 -DomainName KPCHRRAD

#----------------------------------------

#Example usage of the Get-ACL cmdlet. Want to create a module that can true up ACLs.
Get-Acl -Path C:\Users\tfrasier\Test | Format-Table -Wrap
Get-Acl -Path C:\Users\tfrasier\Test\Test1.txt | Format-Table -Wrap

#----------------------------------------

#Function to connection to RabbitMQ API and retrieve information

function Get-RabbitMQQueues {
    #Collecting RabbitMQ Queue information
    Write-Host "Collecting RabbitMQ Queue Information and writing to RabbitMQShovels.txt..." -ForegroundColor Yellow -NoNewline
   
    #Encode authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "guest", "guest")))

    #Connect via API and pull Shovel Information
    $rabbitmqqueues = Invoke-RestMethod -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } -Uri "http://localhost:15672/api/queues"

    # Write $rabbitmqshovels to file
    #Add-Content -Path "$FolderPath\RabbitMQShovels.txt" -Value $rabbitmqshovels

    Write-Host $rabbitmqqueues

    Write-Host "Done" -ForegroundColor Green
}

#----------------------------------------

#Example code to listen on a port for port testing

$Listener = [System.Net.Sockets.TcpListener]9999;
$Listener.Start();
#wait, try connect from another PC etc.
$Listener.Stop();

#----------------------------------------

#Function to find Blocked Files

#function Get-BlockedFiles {
#    Get-Item .\* -stream "Zone.Identifier" -ErrorAction SilentlyContinue | Select-Object FileName
#}

#----------------------------------------

#Function to Unblock files
function Unblock-Files {
Get-ChildItem -Recurse | Unblock-File
}

#----------------------------------------

#Get a list of users and when their passwords were last set.

Get-Aduser -filter * -properties passwordlastset |Format-Table Name, passwordlastset