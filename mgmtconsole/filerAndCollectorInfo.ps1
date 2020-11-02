#Displays file server hostname, associated collector, last filewalk timestamp, and last filewalk status.
#tested on: 
#- DatAdvantage version 5.8.81
#- Windows server 2008r2 SP1
#- PowerShell 3.0

#jonathan@varonis.com

Import-Module VaronisManagement
Connect-Idu


$statusArray = @()

$collectors = Get-Collector
$filerList = Get-FileServerID
$filerList | foreach-object {
     
    #file server info
    $filerID = $_
    $filer = Get-fileServer -fileserverID $filerID
       
    #collector info
    $collectorID = $filer.CollectorID
    $collector = $collectors | where{$_.ID -eq $collectorID}
    
    #job execution info
    $tmpFilewalkText = "filewalk " + $filer.ServerName
    $jobID = get-jobid -name $tmpFilewalkText
    $lastFwRun = Get-LastJobExecution -ID $jobID
    
        
    #formatting output
    #''
    #'FilerID: ' + $filerID
    #'Hostname: ' + $filer.PhysicalHost 
    #'Collector: ' + $collector.DisplayName 
    #'Filewalk date: ' + $lastFwRun.TimeFinished  
    #'Filewalk status: ' + $lastFwRun.AggregatedStatus
    #''
    $obj = New-Object –TypeName PSObject
    $obj | Add-Member NoteProperty -Name FilerID -value $filerID
    $obj | Add-Member NoteProperty -Name Hostname -value $filer.PhysicalHost 
    $obj | Add-Member NoteProperty -Name Collector -value $collector.DisplayName
    $obj | Add-Member NoteProperty -Name LastRun -value $lastFwRun.TimeFinished
    $obj | Add-Member NoteProperty -Name Status -value $lastFwRun.AggregatedStatus
    $statusArray += $obj
    
}

Write-Output $statusArray | Format-Table 

#'Complete'