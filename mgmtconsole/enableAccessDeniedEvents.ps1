# Enables access denied events for list of file servers
# DA version: 6.2.6
#

# List of filers to modify
$filerList = "c:\filersToModify.csv"

Import-Module VaronisManagement
connect-idu

$filers = import-csv $filerList


"----------"

$filers | foreach-object {
    $hostname = ""
    $filerID = ""

    $hostname = $_.hostname
    $filer = Get-FileServer -Name $hostname
    
    
    $filer.config.AccessDeniedEvents = $true
    "Enabling access denied events on: " + $hostname
    
    $jobID = Set-FileServer -FileServer $filer -ForceRepair  
    " - Check management console for " + $hostname + " status"


}
"----------" 
"Complete"