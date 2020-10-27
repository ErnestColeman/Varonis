$DestinationFolder = $Home + "\Desktop\Send to Varonis" #Change path
$LogNames = (Get-WinEvent -ListLog "Varonis*","vrns*","system","application" | where{$_.RecordCount -gt 0}).LogName #Only gets event logs with events present
#If (!(Test-Path $DestinationFolder)) {New-Item $DestinationFolder -Type Directory -Force} #If the $destinationFolder does not exist, then this creates a new folder.
$DateTime = "$(Get-Date -Format "yyyyMMdd-HHmmss")"
$FinalPath = "$($DestinationFolder)\$($DateTime)"


If (!(Test-Path $FinalPath)) {New-Item $FinalPath -Type Directory -Force} #If the $FinalPath does not exist, then this creates a new folder.
Foreach ($Log in $LogNames) {
    $LogNamesFolder = "$($FinalPath)\$($env:computername + '_' + $Log.Replace("/","_"))" + ".evtx"
    wevtutil epl $Log $LogNamesFolder /ow:true #exports log, overwrites existing log
    "Done"
}

Compress-Archive -Path "$($FinalPath)\*" -CompressionLevel Optimal -DestinationPath "$($FinalPath)\$($env:computername)_VarLogs" 
Remove-Item "$($FinalPath)\*.evtx"
"Logs Zipped!"