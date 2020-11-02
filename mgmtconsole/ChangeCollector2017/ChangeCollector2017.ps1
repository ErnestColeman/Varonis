<#
    8/11/2017 
    
    Re-associates monitored fileserver with a different collector.

    Created for version 6.0.112

    Notes: 
    - Both the file server and collector MUST exist in the MC


#>

$dateStamp = get-date -Format yyyyMMdd

#Set these variables
$filerList = import-csv "C:\Varonis\BulkAddFilers\ChangeCollector2017\changeCollector.csv"
$statusList = "C:\Varonis\BulkAddFilers\ChangeCollector2017\$dateStamp-ChangeCollectorStatusList.txt"
$varUser = '' # filewalk user
$varPw = '' # filewalk user password


Import-module VaronisManagement
Connect-Idu


# create credential 
$varCred = New-VaronisCredential -Username $varUser -Password $varPw

# keep track of progress
$count = 0
$totalFilers = $filerList | Measure-Object | Select-Object -expand count

# update filers with new collector
$filerList | ForEach-Object {

    try {
        clear-variable filerHostname, colHostname, filer, col
    }
    catch {

    }

    $filerHostname = $_.hostname
    $colHostname = $_.collector
    
    echo "[$count/$totalFilers] - $filerHostname"


    # Get the file server object
    echo " - Verifying fileserver $filerHostname"
    $filer = Get-FileServer -Name $filerHostname -ErrorVariable errorGetFiler
    
    # if there is an error, log it and move to the next file server
    if ($errorGetFiler){
        $errorMessage = $errorGetFiler.Exception.Message -split [environment]::NewLine
        $errorMessage2 = $errorMessage[1]
        Write-Host -ForegroundColor Red " - Error on $filerHostname"
        Add-Content -Path $statusList "$filerHostname,$errorMessage2"
    }

    # if getting the file server object succeeded, get the collector object
    else {
        echo " - Verifying collector $colHostname"
        $col = Get-Collector -Name $colHostname -ErrorVariable errorGetCol
        
        # if there is an error, log it and move to the next filer server
        if ($errorGetCol){
            $errorMessage = $errorGetCol.Exception.Message -split [environment]::NewLine
            $errorMessage2 = $errorMessage[1]
            Write-Host -ForegroundColor Red " - Error on $colHostname"
            Add-Content -Path $statusList "$filerHostname,$errorMessage2"
        }

        # if getting the collector object succeeds, commit the change in the MC
        else {
            echo " - Committing change to MC"
            $applyChange = Set-FileServer $filer -Collector $col -CollectorCredential $varCred  -ErrorVariable errorSetFiler

            # if there is an error, log it and move to the next filer server
            if ($errorSetFiler){
                $errorMessage = $errorSetFiler.Exception.Message -split [environment]::NewLine
                $errorMessage2 = $errorMessage[1]
                Write-Host -ForegroundColor Red " - Error committing to MC"
                Add-Content -Path $statusList "$filerHostname,$errorMessage2"
            }
        }
    }
}


Disconnect-Idu


















