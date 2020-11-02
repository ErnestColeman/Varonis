<# 

Bulk removes file servers from the Management Console and uninstalls Varonis agent
loads a csv file of hostnames under a "hostname" header

If you do not want to remove the file server agent, comment out the "-RemoveFilerAgent" flag
in the "Remove-FileServer" command

Tested on version 6.0.112

When removing SharePoint webapps, only use the hostname. Remove the http:// prefix
ie. The Management Console will list monitored SharePoint sites as "http://websiteName"
    In your load file, only list "websiteName"



#>

# List of filers to remove
$filerList = "C:\Users\jonathan\Desktop\removeFilers\filers.csv"

Import-Module VaronisManagement
$connect = Connect-IDU

# enter credentials to remove file server agent
$creds = New-Varoniscredential -username "jt\varonis" -password "password1" -type Windows

$filers = import-csv $filerList
$totalFilers = $filers | Measure-Object | Select-Object -expand count

$startTime = get-date -DisplayHint DateTime


"Total fileservers to remove: " + $totalFilers
"Start time: " + $startTime
$counter = 0

"----------"

$filers | foreach-object {

    
    $filerName = $_.hostname

    $counter++

    $filer = Get-FileServer -Name $filerName
    $filerID = $filer.FilerID

    "[" + $counter + " of " + $totalFilers + "] Removing " + $filerName + " from Varonis"
    
    $job = Remove-FileServer -FileServerId $filerID -AgentCredentials $creds -RemoveFilerAgent
    "- Check Management Console for status"

}
$endTime = get-date -DisplayHint DateTime

$duration = $endTime - $startTime


"----------"
"COMPLETE"
" - Start Time: " + $startTime
" - End Time:   " + $endTime
" - Duration:   " + $duration 

Write-Host -NoNewLine 'Press any key to close...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');