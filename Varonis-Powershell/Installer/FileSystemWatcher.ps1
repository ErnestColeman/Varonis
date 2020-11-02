<#
By Tim Frasier
September 5, 2019
#>

$Global:folder = 'C:\Test\' # Enter the root path you want to monitor.
#TODO: Need to set a default location 
$filter = '*.txt'  # You can enter a wildcard filter here.
#TODO: Is this the best default for this?

# In the following line, you can change 'IncludeSubdirectories to $true if required.
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false; NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite' }
#TODO: Is this the best default for this?     

Write-Host "== Monitoring $folder for new $filter files ==" -ForegroundColor Green

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    $arguments = "-noexit -command Get-Content -Path `'" + $folder + $name + "`' -wait"
    Write-Host "The file '$name' was $changeType at $timeStamp" -ForegroundColor White
    Start-Process PowerShell -ArgumentList $arguments
}

# To stop the monitoring, run the following commands:
#Unregister-Event FileCreated