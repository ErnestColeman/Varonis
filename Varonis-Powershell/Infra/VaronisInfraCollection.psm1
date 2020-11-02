<#----------------------------------------
.SYNOPSIS

Collects data for Varonis Infra Escalations

.DESCRIPTION

The VaronisInfraCollection.psm1 script updates the registry with new data generated
during the past month and generates a report.

.INPUTS

None. You cannot pipe objects to VaronisInfraCollection.psm1.

.OUTPUTS

None. VaronisInfraCollection.psm1 does not generate any output.

.EXAMPLE

PS> Import-Module -Name VaronisInfraCollection.psm1 ; Get-InfraInfo

----------------------------------------#>

# # # # Defining Functions

# # # General

# # Run it

function Get-InfraInfo {
    #Kick off data collection

    Write-Host 'Starting InfraEscalation Data Collection Process...' -ForegroundColor Cyan

    Get-ServerRole

    if ($ServerRole -eq 'IDU, Probe') {
        Write-Host 'Server detected as DSP. Starting DSP Infra Collection...' -ForegroundColor Yellow
        Get-DSPInfo
    }
    elseif ($ServerRole -eq 'Collector') {
        Write-Host 'Server detected as Collector. Starting Collector Infra Collection...' -ForegroundColor Yellow
        Get-CollectorInfo
    }
    else {
        Write-Host 'Server role detection failed.' -ForegroundColor Red
    }
}

# # Host Identification

function Get-ServerRole {
    #Read Varonis IDU Server Registry Key into variable $ServerRole
    $Script:ServerRole = (Get-ItemProperty -Path 'HKLM:\Software\Varonis\IDU Server\').Role
}

# # Housekeeping

function Reset-InfraCollection {
    # Cleanup previous run
    <#Legacy Method
    Remove-Item -Path 'C:\Varonis_Temp' -Recurse -Force -ErrorAction SilentlyContinue #>
    Remove-Item -Path "C:\Varonis_Infra_*" -Recurse -Force -ErrorAction SilentlyContinue
}
function New-InfraCollectionFolder {
    # Create Base Folder for storing data collected during this run
    Write-Host "Creating Collection Folder on C:..." -ForegroundColor Yellow -NoNewline
    
    #Generate Folder Path
    $DateString = Get-Date -Format FileDateTime
    $Script:FolderPath = "C:\Varonis_Infra_$DateString"
    <#Legacy Method
    $Script:FolderPath = "C:\Varonis_Temp" -ItemType Directory | Out-Null #>
    
    New-Item -Path $FolderPath -ItemType Directory | Out-Null
    
    Write-Host "Done" -ForegroundColor Green
    Write-Host "Collection folder is $FolderPath"
}
function Open-InfraCollectionFolder {
    #Open the Collection folder
    Invoke-Item "$FolderPath"
}
# # # RabbitMQ

# # Files

function Get-RabbitMQLogs {
    # Collect RabbitMQ Log Files
    Write-Host "Creating RabbitMQ_Logs Folder..." -ForegroundColor Yellow -NoNewline

    #Create Folder 'RabbitMQ_Logs' to store logs
    New-Item -Path "$FolderPath\RabbitMQ_Logs" -ItemType Directory | Out-Null

    Write-Host "Done" -ForegroundColor Green

    Write-Host "Copying RabbitMQ Logs..." -ForegroundColor Yellow -NoNewline

    #Copy contents of RabbitMQ log folder into 'RabbitMQ_Logs'
    Copy-Item -Path $env:RABBITMQ_BASE\Log\* -Destination "$FolderPath\RabbitMQ_Logs\"

    Write-Host "Done" -ForegroundColor Green
}
function Get-RabbitMQConfig {
    # Collect Rabbitmq.config file
    Write-Host "Copying Rabbitmq.Config file..." -ForegroundColor Yellow -NoNewline

    Copy-Item -Path "$env:RABBITMQ_BASE\rabbitmq.config" -Destination $FolderPath

    Write-Host "Done" -ForegroundColor Green
}
function Get-RabbitMQDumps {
    # Collect any Dump files from %AppData%\RabbitMQ
    Write-Host "Creating RabbitMQ_Dumps Folder..." -ForegroundColor Yellow -NoNewline

    New-Item -Path "$FolderPath\RabbitMQ_Dumps" -ItemType Directory | Out-Null

    Write-Host "Done" -ForegroundColor Green

    Write-Host "Collecting any dump files from RabbitMQ Appdata folder..." -ForegroundColor Yellow -NoNewline

    Copy-Item -Path $env:APPDATA\RabbitMQ\*.dump -Destination "$FolderPath\RabbitMQ_Dumps\"

    Write-Host "Done" -ForegroundColor Green

}
# # Data

# RabbitMQ .bat Executions

function Get-RabbitMQctlStatus {

    # Collect 'Rabbitmqctl.bat status' output
    Write-Host "Collecting ouput of 'RabbitmqCTL.bat status'..." -ForegroundColor Yellow -NoNewline

    # Run 'RabbitMQctl.bat status' and collect output to variable $rabbitmqctlstatus
    $rabbitmqctlstatus = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\rabbitmqctl.bat" status

    # Write content of $rabbitmqstatus to Rabbitmqstatus.txt
    Add-Content -Path "$FolderPath\RabbitmqStatus.txt" -Value $rabbitmqctlstatus

    Write-Host "Done" -ForegroundColor Green
}
function Get-RabbitMQPluginsList {

    # Collect 'Rabbitmq-plugins.bat list' output
    Write-Host "Collecting Output of 'Rabbitmq-plugins.bat list'..." -ForegroundColor Yellow -NoNewline

    # Run 'Rabbitmq-plugins.bat list' and collect output to variable $rabbitmqplugins
    $rabbitmqplugins = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\Rabbitmq-plugins.bat" list

    # Write content of $rabbitmqplugins to RabbitMQPlugins.txt
    Add-Content -Path "$FolderPath\RabbitMQPlugins.txt" -Value $rabbitmqplugins

    Write-Host "Done" -ForegroundColor Green
}

# Interfacing with Web API

function Get-RabbitMQcltShovels {
    #Collecting RabbitMQ Shovel information
    Write-Host "Collecting RabbitMQ Shovel Information and writing to RabbitMQShovels.txt..." -ForegroundColor Yellow -NoNewline

    # Run 'Rabbitmqctl.bat eval 'rabbit_shovel_status:status().' to $rabbitmqshovels - Depricated for API solution by Brian Amos
    #$rabbitmqshovels = & "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.6.10\sbin\rabbitmqctl.bat" eval 'rabbit_shovel_status:status().'
    
    #Encode authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "guest", "guest")))

    #Connect via API and pull Shovel Information
    $rabbitmqshovels = Invoke-RestMethod -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } -Uri "http://localhost:15672/api/shovels"

    # Write $rabbitmqshovels to file
    Add-Content -Path "$FolderPath\RabbitMQShovels.txt" -Value $rabbitmqshovels

    Write-Host "Done" -ForegroundColor Green
}

# # # Varonis Data

# # Files

function Get-ZippedInstallerLogs {
    # Collect Zipped Installer Logs
    Write-Host "Creating Installer_Logs folder..." -ForegroundColor Yellow -NoNewline

    New-Item -Path "$FolderPath\Installer_Logs" -ItemType Directory | Out-Null

    Write-Host "Done" -ForegroundColor Green

    Write-Host "Copying all Varonis Installer_*.zip files..." -ForegroundColor Yellow -NoNewline

    Get-ChildItem -Path 'C:\Program Files (x86)\Varonis\DatAdvantage\IDU Server\Logs\' -Filter Installer_* | Copy-Item -Destination $FolderPath\Installer_Logs

    Write-Host "Done" -ForegroundColor Green
}
# Varonis Log Files
function Get-TopologyManagerLogs {
    
    # Collect Topology Manager Logs
    Write-Host "Checking for TopologyManager folder..." -ForegroundColor Yellow -NoNewline

    $TopolgyManagerFolder = Test-Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\Logs'
    if ($TopolgyManagerFolder -eq $True) {
        Write-Host "Topology Folder Found!" -ForegroundColor Green
        Write-Host "Creating Topology_Manager Folder..." -ForegroundColor Yellow -NoNewline
        New-Item -Path "$FolderPath\Topology_Manager" -ItemType Directory | Out-Null
        
        Write-Host "Done" -ForegroundColor Green
        Write-Host "Copying TopologyManager Logs..." -ForegroundColor Yellow -NoNewline
        Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\Logs' -Destination $FolderPath\Topology_Manager
        
        Write-Host "Done" -ForegroundColor Green
        Write-Host "Collecting TopologyManager .dmp files..." -ForegroundColor Yellow -NoNewline
        
        Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\*.dmp' -Destination $FolderPath\Topology_Manager
        Write-Host "Done" -ForegroundColor Green
        
        Write-Host "Collecting TopologyManager .zip files..." -ForegroundColor Yellow -NoNewline
        Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\*.zip' -Destination $FolderPath\Topology_Manager
        
        Write-Host "Done" -ForegroundColor Green
    }
    else { Write-Host "TopologyManager Folder not found. Skipping" -ForegroundColor Green }
}
function Get-SyncManagerLogs {
    # Collect SyncManager Logs
    Write-Host "Checking for SyncManager folder..." -ForegroundColor Yellow

    $SyncManagerFolder = Test-Path "$FolderPath\SyncManager"
    if ($SyncManagerFolder -eq $True) {
        Write-Host "SyncManager Folder found..." -ForegroundColor Yellow
        Write-Host "Creating SyncManager Folder..." -ForegroundColor Yellow -NoNewline
        New-Item -Path "$FolderPath\SyncManager" -ItemType Directory | Out-Null
        
        Write-Host "Done" -ForegroundColor Green
        Write-Host "Copying SyncManger Logs..." -ForegroundColor Yellow -NoNewline
        Copy-Item -Path 'C:\Program Files\Varonis\DatAdvantage\SyncManager\Logs' -Destination $FolderPath\SyncManager
        
        Write-Host "Done" -ForegroundColor Green
    }
    else { Write-Host "SyncManager Folder not found. Skipping" -ForegroundColor Green }
}
# Registry
function Get-VaronisRegistryKey {
    # Export registry settings under HKEY_LOCAL_MACHINE\SOFTWARE\Varonis
    Write-Host "Exporting HKEY_LOCAL_MACHINE\SOFTWARE\Varonis to Varonis.reg file..." -ForegroundColor Yellow -NoNewline

    Reg Export 'HKLM\SOFTWARE\Varonis' "C:\Windows\Temp\Varonis.reg" | Out-Null

    Move-Item -Path "C:\Windows\Temp\Varonis.reg" -Destination $FolderPath

    Write-Host "Done" -ForegroundColor Green
}

# Other Varonis Files
function Get-VaronisInfraLogDllVersion {
    # Collect Varonis.Infra.Log.dll version
    Write-Host "Collecting Varonis.Infra.Log.dll Version and writing to VaronisInfraLogDLLVersion.txt..." -ForegroundColor Yellow -NoNewline

    $VaronisInfraLogdllversion = (Get-Item -Path 'C:\Program Files\Varonis\DatAdvantage\TopologyManager\Varonis.infra.log.dll').VersionInfo.FileVersion

    Add-Content -Path "$FolderPath\VaronisInfraLogDLLVersion.txt" -Value "Varonis.Infra.Log.dll version is $VaronisInfraLogdllversion"

    Write-Host "Done" -ForegroundColor Green
}
# # # Windows Information

# # Event Logs
function Get-EventLogs {
    # Collect Windows Event Logs
    Write-Host "Creating Event_Logs folder..." -ForegroundColor Yellow -NoNewline

    New-Item -Path $FolderPath\Event_Logs -ItemType Directory | Out-Null

    Write-Host "Done" -ForegroundColor Green

    # Windows Application Event Log
    Write-Host "Exporting Application Event Log..." -ForegroundColor Yellow -NoNewline

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Application').BackupEventlog("$FolderPath\Event_Logs\Application.evtx") | Out-Null

    Write-Host "Done" -ForegroundColor Green

    # Windows System Event Log
    Write-Host "Exporting System Event Log..." -ForegroundColor Yellow -NoNewline

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'System').BackupEventlog("$FolderPath\Event_Logs\System.evtx") | Out-Null

    Write-Host "Done" -ForegroundColor Green

    # Windows Setup Event Log
    Write-Host "Exporting Setup Event Log..." -ForegroundColor Yellow -NoNewline

    wevtutil epl Setup "$FolderPath\Event_Logs\Setup.evtx"

    Write-Host "Done" -ForegroundColor Green

    # Varonis Event Log
    Write-Host "Exporting Varonis Event Log..." -ForegroundColor Yellow -NoNewline

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Varonis').BackupEventlog("$FolderPath\Event_Logs\Varonis.evtx") | Out-Null

    Write-Host "Done" -ForegroundColor Green

    # Varonis Externals Event Log
    Write-Host "Exporting Varonis.Externals Event Log..." -ForegroundColor Yellow -NoNewline

    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Varonis.Externals').BackupEventlog("$FolderPath\Event_Logs\Varonis.Externals.evtx") | Out-Null

    Write-Host "Done" -ForegroundColor Green
}

# # Services
function Get-ServiceStatuses {
    # Collect Service Statuses
    Write-Host "Collecting Service statuses and writing to Services.txt..." -ForegroundColor Yellow

    $varonisvsbtopologymanagerstatus = (Get-Service -Name Varonis.Vsb.TopologyManager).Status
    Write-Host "Varonis VSB Topology Manger Service is $varonisvsbtopologymanagerstatus." -ForegroundColor Yellow
    Add-Content -Path "$FolderPath\Services.txt" -Value "Varonis VSB Topology Manger Service is $varonisvsbtopologymanagerstatus."

    $varonisvsbkeyvaluestorestatus = (Get-Service -Name Varonis.VSBKVService).Status
    Write-Host "Varonis VSB Key Value Store Service is $varonisvsbkeyvaluestorestatus" -ForegroundColor Yellow
    Add-Content -Path "$FolderPath\Services.txt" -Value "Varonis VSB Key Value Store Service is $varonisvsbkeyvaluestorestatus"

    $varonisvsbconfigurationstatus = (Get-Service -Name VSBConfigurationSvc).Status
    Write-Host "Varonis VSB Configuration Service is $varonisvsbconfigurationstatus" -ForegroundColor Yellow
    Add-Content -Path "$FolderPath\Services.txt" -Value "Varonis VSB Configuration Service is $varonisvsbconfigurationstatus"

    $vaornisvsbsupervisorstatus = (Get-Service -Name Varonis.Infra.Vsb.SupervisorSvc).Status
    Write-Host "Varonis VSB Supervisor Service is $vaornisvsbsupervisorstatus" -ForegroundColor Yellow
    Add-Content -Path "$FolderPath\Services.txt" -Value "Varonis VSB Supervisor Service is $vaornisvsbsupervisorstatus"

    $varonisinfrahealthstatus = (Get-Service -Name Varonis.Infra.VSB.HealthService).Status
    Write-Host "Varonis Infra Health Service is $varonisinfrahealthstatus" -ForegroundColor Yellow
    Add-Content -Path "$FolderPath\Services.txt" -Value "Varonis Infra Health Service is $varonisinfrahealthstatus"

    Write-Host "Get-ServiceStatuses Complete" -ForegroundColor Green
}

# # # System

# # Housekeeping
function New-SystemFolder {
    Write-Host "Creating System folder..." -ForegroundColor Yellow -NoNewline

    New-Item -Path "$FolderPath\System" -ItemType Directory | Out-Null

    Write-Host "Done" -ForegroundColor Green
}

# # OS Information
function Get-SystemInfo {
    # Collect Windows Version Information
    Write-Host "Collecting output of Get-ComputerInfo cmdlet and writing to Systeminfo.txt..." -ForegroundColor Yellow -NoNewline
    
    # Depricated in favor of Get-ComputerInfo
    # $sysinfo = systeminfo

    $sysinfo = systeminfo.exe

    Add-Content -Path "$FolderPath\System\Systeminfo.txt" -Value $sysinfo

    Write-Host "Done" -ForegroundColor Green
}
function Get-WinUpdates {
    # Collect Applied Windows Updates
    Write-Host "Collecting Applied Windows Updates and writing to WindowsUpdates.txt..." -ForegroundColor Yellow -NoNewline

    $winupdates = Get-WmiObject -Class win32_quickfixengineering

    Add-Content -Path "$FolderPath\System\WindowsUpdates.txt" -Value $winupdates

    Write-Host "Done" -ForegroundColor Green
}
function Get-InstalledHotfixes {
    # Collect ouput of Get-Hotfix
    Write-Host "Collecting output of Get-Hotfix and writing to Hotfixes.txt..." -ForegroundColor Yellow -NoNewline

    Get-HotFix | Out-File "$FolderPath\System\Hotfixes.txt"

    Write-Host "Done" -ForegroundColor Green
}
# # Networking
function Get-NetStat {
    # Collect ouput of Netstat -na
    Write-Host "Running NetStat -na and collecting writing output to Netstat.txt..." -ForegroundColor Yellow -NoNewline

    netstat -na | Out-File "$FolderPath\Netstat.txt"

    Write-Host "Done" -ForegroundColor Green
}
# # Storage
function Get-DiskInfo {
    # Collect Avaiable Diskspace Information
    Write-Host "Collecting drive volume information and writing to Storage.txt..." -ForegroundColor Yellow -NoNewline

    Get-PSDrive | Out-File "$FolderPath\System\Storage.txt"

    Write-Host "Done" -ForegroundColor Green
}

# # # Where the Magic Happens (Execution options for DSP and Collectors)
function Get-DSPInfo {
    #Collect information set from DSP server

    #Setup Base Folder
    Write-Host "Configuring base folder structure..." -ForegroundColor White
    Reset-InfraCollection
    New-InfraCollectionFolder
    
    #Collect Event Logs
    Write-Host "Data Collection Starting... " -ForegroundColor White
    
    Write-Host "Collecting Event Log Data... " -ForegroundColor White
    Get-EventLogs

    Write-Host "Collecting System Data... " -ForegroundColor White
       
    #Collect System Information
    New-SystemFolder
    Get-SystemInfo
    Get-WinUpdates
    Get-InstalledHotfixes
    Get-NetStat
    Get-DiskInfo
        
    #Collect Misc
    Write-Host "Collecting Varonis Data... " -ForegroundColor White
    Get-ZippedInstallerLogs
    Get-TopologyManagerLogs
    Get-SyncManagerLogs
    Get-ServiceStatuses
    Get-VaronisInfraLogDllVersion
    Get-VaronisRegistryKey

    #Collect RabbitMQ Data
    Write-Host "Collecting RabbitMQ Data... " -ForegroundColor White
    Get-RabbitMQLogs
    Get-RabbitMQctlStatus
    Get-RabbitMQPluginsList
    Get-RabbitMQcltShovels
    Get-RabbitMQConfig
    Get-RabbitMQDumps


    Write-Host "Data Collection Complete." -ForegroundColor White
    
    #Open Base Folder
    Write-Host "Process Complete. Opening Collection Folder..." -ForegroundColor Cyan
    Open-InfraCollectionFolder
}
function Get-CollectorInfo {
    Get-DSPInfo
}