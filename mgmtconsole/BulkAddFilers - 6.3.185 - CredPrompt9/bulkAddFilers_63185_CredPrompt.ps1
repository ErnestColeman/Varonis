<#
    Updated 10/2017

    6.3.185

    Bulk adds file servers to the Management Console.
    
    Currently Windows only


    Instructions:
    1. Update the '$filerList' and '$statusList' variables below
        - filerList: csv containing list of filers and associated collector. The 
            collector must be added to the Management Console before running this script
        - statusList: general commit log showing success/failure messages per filer
    2. Run script as Administrator
    3. It will prompt for Filewalk, Agent install, SQL host, database, and Collector credentials
    4. View Management Console for filer add status
    5. Management Console add error logs are located in ..\IDU Server\Logs\Deployment


#>
$dateStamp = get-date -Format yyyyMMdd

$filerList = "C:\Users\jonathan\Desktop\BulkAddWindowsFilers2017_2\2017Deployment_SAMPLE.csv"
$statusList = "C:\Users\jonathan\Desktop\BulkAddWindowsFilers2017_2\$dateStamp-BulkAddFilersStatusList.txt"

# Common variables
$filerType = "windows"
$probeID = "1"
$skipInstallFwAgent = $false
$skipInstallEventAgent = $false
$collectLocalAcct = $true

Import-Module VaronisManagement
Connect-Idu

# Prompt for credentials
Write-Host -ForegroundColor Yellow "Enter Filewalk Credentials"
$fwCred = New-Varoniscredential -type Windows

Write-Host -ForegroundColor Yellow "Enter Agent Install Credentials"
$agentCred = New-Varoniscredential -type Windows

Write-Host -ForegroundColor Yellow "Enter SQL Host Credentials"
$dbServerCred = New-Varoniscredential

Write-Host -ForegroundColor Yellow "Enter Database Credentials"
$dbSQLCred = New-Varoniscredential -type Windows

Write-Host -ForegroundColor Yellow "Enter Collector Host Credentials"
$collectorCred = New-Varoniscredential -Type Windows
        
#for loop to add the servers in the list.
$filerInfo = import-csv $filerList

#counter to display progress
$counter = 0
$totalFilers = $filerInfo | Measure-Object | Select-Object -expand count

$filerInfo | foreach-object {
    
    # clear existing variables at the beginning of each run
    Clear-Variable -ErrorAction SilentlyContinue hostname,
            collectorID,
            collector,
            filer,
            newFilerError,
            addFilerError

    #general variables from csv
    $hostname = $_.hostname
    $collectorID = Get-Collector -name $_.collector
    $collector = $_.collector
    
    $counter++
    echo "[$counter/$totalFilers] - Adding $hostname to $collector"

    # Test machine is up
    if ((Test-Connection $hostname -quiet -count 1) <#-AND (Test-Path "\\$hostname\ADMIN$") #>){
        Write-Host -ForegroundColor Green " - $hostname is up"

        # try adding the server to the MC
        
        # Here we are building out cases (ie..if the filer is windows, do these steps)
        switch ($filerType) 
        { 
            "windows" {
                $filer = New-WindowsFileServer -name $hostname -AddToFilteredUsers $true -FileWalkCredentials $fwcred -AgentCredentials $agentCred -ShadowSqlCredential $dbSQLCred -DBInstallCredential $dbServerCred -ProbeID $probeID -collector $collectorID –DiscoverShares TopLevelOnly -ErrorVariable newFilerError
                    
                if ($newFilerError) {
                    $errorMessage = $newFilerError.Exception.Message -split [environment]::NewLine
                    $errorMessage2 = $errorMessage[1]
                    Write-Host -ForegroundColor Red " - Error adding $hostname"
                    Add-Content -Path $statusList "$hostname,$collector,$errorMessage2"
                }
                else {
                    #Specify we do not want driver to be installed
                    $filer.Config.SkipFileWalkChange = $skipInstallFwAgent
                    $filer.Config.IgnoreDriverChanges = $skipInstallEventAgent
                    $filer.Config.All.CollectLocalAccountsInfo = $collectLocalAcct
                    #possible values:
                    # 1 = unchecked
                    # 32774 - checked 
                    $filer.Config.All.OpenReadEvents = 32774
                    Write-Host " - Adding $hostname to Management Console queue"
                    Add-fileserver $filer -CollectorCredential $collectorCred -Force -ErrorVariable addFilerError
                    
                    if ($addFilerError) {
                        $errorMessage = $addFilerError.Exception.Message -split [environment]::NewLine
                        $errorMessage2 = $errorMessage[1]
                        Write-Host -ForegroundColor Red " - Error adding $hostname"
                        Add-Content -Path $statusList "$hostname,$collector,$errorMessage2"
                    }
                    else {
                        Add-Content -Path $statusList "$hostname,$collector,Success"
                    }
                }
            }
        }
    }
    else {

        Write-Host -ForegroundColor Red " - ERROR: $hostname is down"
        $connectError = "$hostname,$collector,Error: Server down"
        Add-Content -Path $statusList "$hostname,$collector,Server down"
    }
}

Disconnect-Idu