# Enables incremental filewalk on ALL file servers
# DA version: 6.0.95
#
# Author: jonathan@varonis.com

connect-idu
Import-Module VaronisManagement

$filers = Get-FileServer 

"----------"

$filers | foreach-object {
    $hostname = ""
    $filerID = ""

    $filer = $_
    $hostname = $_.DisplayName
    $filerID = $_.FilerID
    
    
    $filer.config.IsFwIncEnabled = $true 
    
    "Enabling Incremental Filewalk on: " + $hostname
    $jobID = Set-FileServer -FileServer $filer -ForceRepair 
    " - Check management console for " + $hostname + " status"
}
"----------" 
"Complete"

