<#----------------------------------------
.SYNOPSIS

Collects data for Varonis Infra Escalations

.DESCRIPTION

The Get-RabbitmqEscalationData.ps1 script updates the registry with new data generated
during the past month and generates a report.

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.PARAMETER OutputPath
Specifies the name and path for the CSV-based output file. By default,
MonthlyUpdates.ps1 generates a name from the date and time it runs, and
saves the output in the local directory.

.INPUTS

None. You cannot pipe objects to Get-RabbitmqEscalationData.ps1.

.OUTPUTS

None. Get-RabbitmqEscalationData.ps1 does not generate any output.

.EXAMPLE

PS> .\Get-RabbitmqEscalationData.ps1

----------------------------------------#>

#Create Folder for evenything to be copied to
Write-Host "Creating Varonis_Temp Folder..." -ForegroundColor Yellow  -NoNewLine

    New-Item -Path C:\Varonis_Temp -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

##RabbitMQ Files

#Collect RabbitMQ Log Files
Write-Host "Creating RabbitMQ_Logs Folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\RabbitMQ_Logs' -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

Write-Host "Copying RabbitMQ Logs..." -ForegroundColor Yellow  -NoNewLine

    Copy-Item -Path $env:RABBITMQ_BASE\Log\* -Destination 'C:\Varonis_Temp\RabbitMQ_Logs\'

Write-Host "Done" -ForegroundColor Green

#Collect 'Rabbitmqctl.bat status' output
Write-Host "Collecting ouput of 'RabbitmqCTL.bat status'..." -ForegroundColor Yellow  -NoNewLine

    $rabbitmqctlstatus = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\rabbitmqctl.bat" status

Add-Content -Path C:\Varonis_Temp\RabbitmqStatus.txt -Value $rabbitmqctlstatus

Write-Host "Done" -ForegroundColor Green

#Collect 'Rabbitmq-plugins.bat list' output
Write-Host "Collecting Output of 'Rabbitmq-plugins.bat list'..." -ForegroundColor Yellow  -NoNewLine

    $rabbitmqplugins = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\Rabbitmq-plugins.bat" list

Add-Content -Path 'C:\Varonis_Temp\RabbitMQPlugins.txt' -Value $rabbitmqplugins

Write-Host "Done" -ForegroundColor Green

#Collect 'Rabbitmqctl.bat eval 'rabbit_shovel_status:status().' output
Write-Host "Collecting Output of 'rabbitmqctl.bat eval 'rabbit_shovel_status:status ().''..." -ForegroundColor Yellow  -NoNewLine

    $rabbitmqshovels = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\rabbitmqctl.bat" eval 'rabbit_shovel_status:status().'

Add-Content -Path 'C:\Varonis_Temp\RabbitMQShovels.txt' -Value $rabbitmqshovels

Write-Host "Done" -ForegroundColor Green

#Collect Rabbitmq.config file
Write-Host "Copying Rabbitmq.Config file..." -ForegroundColor Yellow  -NoNewLine

    Copy-Item -Path "$env:RABBITMQ_BASE\rabbitmq.config" -Destination C:\Varonis_Temp\

Write-Host "Done" -ForegroundColor Green

#Collect any Dump files from %AppData%\RabbitMQ
Write-Host "Creating RabbitMQ_Dumps Folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\RabbitMQ_Dumps' -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

Write-Host "Collecting any dump files from RabbitMQ Appdata folder..." -ForegroundColor Yellow  -NoNewLine

    Copy-Item -Path $env:APPDATA\RabbitMQ\*.dump -Destination 'C:\Varonis_Temp\RabbitMQ_Dumps\'

Write-Host "Done" -ForegroundColor Green

##Installer Files

#Collect Zipped Installer Logs
Write-Host "Creating Installer_Logs folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\Installer_Logs' -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

Write-Host "Copying all Varonis Installer_*.zip files..." -ForegroundColor Yellow  -NoNewLine

    Get-ChildItem -Path 'C:\Program Files (x86)\Varonis\DatAdvantage\IDU Server\Logs\' -Filter Installer_* | Copy-Item -Destination C:\Varonis_Temp\Installer_Logs

Write-Host "Done" -ForegroundColor Green

##Event Logs
Write-Host "Creating Event_Logs folder..." -ForegroundColor Yellow  -NoNewLine

    New-Item -Path C:\Varonis_Temp\Event_Logs -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

#Windows Application Event Log
Write-Host "Exporting Application Event Log..." -ForegroundColor Yellow  -NoNewLine

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Application').BackupEventlog('C:\Varonis_Temp\Event_Logs\Application.evtx') | Out-Null

Write-Host "Done" -ForegroundColor Green

#Windows System Event Log
Write-Host "Exporting System Event Log..." -ForegroundColor Yellow  -NoNewLine

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'System').BackupEventlog('C:\Varonis_Temp\Event_Logs\System.evtx') | Out-Null

Write-Host "Done" -ForegroundColor Green

#Windows Setup Event Log
Write-Host "Exporting Setup Event Log..." -ForegroundColor Yellow  -NoNewLine

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Setup').BackupEventlog('C:\Varonis_Temp\Event_Logs\Setup.evtx') | Out-Null

Write-Host "Done" -ForegroundColor Green

#Varonis Event Log
Write-Host "Exporting Varonis Event Log..." -ForegroundColor Yellow  -NoNewLine

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Varonis').BackupEventlog('C:\Varonis_Temp\Event_Logs\Varonis.evtx') | Out-Null

Write-Host "Done" -ForegroundColor Green

#Varonis Externals Event Log
Write-Host "Exporting Varonis.Externals Event Log..." -ForegroundColor Yellow  -NoNewLine

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Varonis.Externals').BackupEventlog('C:\Varonis_Temp\Event_Logs\Varonis.Externals.evtx') | Out-Null

Write-Host "Done" -ForegroundColor Green

##Collect Topology Manager Logs
Write-Host "Creating Topology_Manager Folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\Topology_Manager' -ItemType Directory | Out-Null
Write-Host "Done" -ForegroundColor Green

Write-Host "Copying TopologyManager Logs..." -ForegroundColor Yellow -NoNewLine

    Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\Logs' -Destination C:\Varonis_Temp\Topology_Manager

Write-Host "Done" -ForegroundColor Green

Write-Host "Collecting TopologyManager .dmp files..." -ForegroundColor Yellow -NoNewLine

    Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\*.dmp' -Destination C:\Varonis_Temp\Topology_Manager

Write-Host "Done" -ForegroundColor Green

Write-Host "Collecting TopologyManager .zip files..." -ForegroundColor Yellow -NoNewLine

    Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\*.zip' -Destination C:\Varonis_Temp\Topology_Manager

Write-Host "Done" -ForegroundColor Green

##Collect SyncManager Logs
Write-Host "Creating SyncManager Folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\SyncManager' -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

Write-Host "Copying SyncManger Logs..." -ForegroundColor Yellow -NoNewLine

    Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\SyncManager\Logs' -Destination C:\Varonis_Temp\SyncManager

Write-Host "Done" -ForegroundColor Green

##Collect Service Statuses
Write-Host "Collecting Service statuses and writing to Services.txt..." -ForegroundColor Yellow -NoNewLine

    $varonisvsbtopologymanagerstatus = (Get-Service -Name Varonis.Vsb.TopologyManager).Status

    Add-Content -Path 'C:\Varonis_Temp\Services.txt' -Value "Varonis VSB Topology Manger Service is $varonisvsbtopologymanagerstatus."

    $varonisvsbkeyvaluestorestatus = (Get-Service -Name Varonis.VSBKVService).Status

    Add-Content -Path 'C:\Varonis_Temp\Services.txt' -Value "Varonis VSB Key Value Store Service is $varonisvsbkeyvaluestorestatus"

    $varonisvsbconfigurationstatus = (Get-Service -Name VSBConfigurationSvc).Status

    Add-Content -Path 'C:\Varonis_Temp\Services.txt' -Value "Varonis VSB Configuration Service is $varonisvsbconfigurationstatus"

    $vaornisvsbsupervisorstatus = (Get-Service -Name Varonis.Infra.Vsb.SupervisorSvc).Status

    Add-Content -Path 'C:\Varonis_Temp\Services.txt' -Value "Varonis VSB Supervisor Service is $vaornisvsbsupervisorstatus"

    $varonisinfrahealthstatus = (Get-Service -Name Varonis.Infra.VSB.HealthService).Status

    Add-Content -Path 'C:\Varonis_Temp\Services.txt' -Value "Varonis Infra Health Service is $varonisinfrahealthstatus"

Write-Host "Done" -ForegroundColor Green

##Collect Varonis.Infra.Log.dll version
Write-Host "Collecting Varonis.Infra.Log.dll Version and writing to VaronisInfraLogDLLVersion.txt..." -ForegroundColor Yellow -NoNewLine

    $VaronisInfraLogdllversion = (Get-Item -path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\Varonis.infra.log.dll').VersionInfo.FileVersion

    Add-Content -Path 'C:\Varonis_Temp\VaronisInfraLogDLLVersion.txt' -Value "Varonis.Infra.Log.dll version is $VaronisInfraLogdllversion"

Write-Host "Done" -ForegroundColor Green

##System
Write-Host "Creating System folder..." -ForegroundColor Yellow -NoNewLine

    New-Item -Path 'C:\Varonis_Temp\System' -ItemType Directory | Out-Null

Write-Host "Done" -ForegroundColor Green

#Collect Windows Version Information
Write-Host "Collecting output of systeminfo command and writing to Systeminfo.txt..." -ForegroundColor Yellow -NoNewLine

    $sysinfo = systeminfo

    Add-Content -Path 'C:\Varonis_Temp\System\Systeminfo.txt' -Value $sysinfo

Write-Host "Done" -ForegroundColor Green

#Collect Applied Windows Updates
Write-Host "Collecting Applied Windows Updates and writing to WindowsUpdates.txt..." -ForegroundColor Yellow -NoNewLine

    $winupdates = get-wmiobject -class win32_quickfixengineering

    Add-Content -Path 'C:\Varonis_Temp\System\WindowsUpdates.txt' -Value $winupdates

Write-Host "Done" -ForegroundColor Green

#Collect ouput of Get-Hotfix
Write-Host "Collecting output of Get-Hotfix and writing to Hotfixes.txt..." -ForegroundColor Yellow -NoNewLine

    Get-Hotfix | Out-File 'C:\Varonis_Temp\System\Hotfixes.txt'

Write-Host "Done" -ForegroundColor Green

##Networking

#Collect ouput of Netstat -na
Write-Host "Running NetStat -na and collecting writing output to Netstat.txt..." -ForegroundColor Yellow -NoNewLine

    netstat -na | Out-File 'C:\Varonis_Temp\Netstat.txt'

Write-Host "Done" -ForegroundColor Green

##Storage

#Collect Avaiable Diskspace Information
Write-Host "Collecting drive volume information and writing to Storage.txt..." -ForegroundColor Yellow -NoNewLine

    Get-PSDrive | Out-File 'C:\Varonis_Temp\System\Storage.txt'

Write-Host "Done" -ForegroundColor Green

##Registry

#Export registry settings under HKEY_LOCAL_MACHINE\SOFTWARE\Varonis
Write-Host "Exporting HKEY_LOCAL_MACHINE\SOFTWARE\Varonis to Varonis.reg file..." -ForegroundColor Yellow -NoNewLine

    Reg Export 'HKLM\SOFTWARE\Varonis' 'C:\Varonis_Temp\Varonis.reg' | Out-Null

Write-Host "Done" -ForegroundColor Green