<#
Gets info on monitored file servers and saves it to a csv file.

Hostname
Filer Type
OS
Ping Status 
Collector Name
Event Collection
Event Agent Version
Filewalk Agent Version
IPAddress


Configure the "General Variables" below 

#>


#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


$timestamp = get-date -Format yyyyMMddhhss


# General Variables
########################
$transcriptLog = "C:\File server info\$timestamp-Transcript-filerinfo.txt"
$commitLog = "C:\File server info\$timestamp-filerinfo.csv"


########################
#Start-Transcript -Path $transcriptLog

$createCommitLog = new-item -Path $commitLog -ItemType file
$commitLogHeader = "Hostname,FilerType,OS,Status,CollectorName,EventCollection,EventAgent,FilewalkAgent,IPAddress"
Add-Content -Path $commitLog -Value $commitLogHeader

Import-Module VaronisManagement
Connect-IDU

echo "Getting filer info..."
$filers = Get-FileServer

# counter for progress
$counter = 0
$serverCount = $filers | Measure-Object | Select-Object -expand count #Used to display progress counter

foreach ($filer in $filers) {
       
    $filerHostname = $filer.DisplayName
    $counter++

    echo "[$counter of $serverCount] - $filerHostname"

    $eventCollection = $filer.CollectEvents
    $filerType = $filer.FilerType
    $colID = $filer.CollectorID
    $filerOS = $filer.AdditionalInfo
    $filerOS2 = $filerOS -replace "`t|`n|`r",""
    $filerOS = $filerOS2 -replace " ;|; ",";"
    $IPAddress = $filer.IPAddress

    # Get collector name from ID
    if ($colID -eq 0) {
        $colName = "N/A"
        echo " - Collector: $colName"
    }
    else {
        $collector = get-collector -FeatureID $colID
        $colName = $collector.DisplayName
        echo " - Collector: $colName"
    }
    
        
    # Test connection to get alive status then get agent info
    if(test-connection -ComputerName $filerHostname -quiet) {
        echo " - $filerHostname is UP"
        $filerStatus = "UP"

        if ($filerType -eq "Windows") {
            try {
                echo " - Getting event agent version"
                $eventAgentPath = (Get-WmiObject win32_service -ComputerName $filerHostname | ?{$_.name -eq "VrnsCifsQueue"}).pathname
                $eventAgentPathMod = $eventAgentPath.replace("\VrnsMonSvc.exe","")
                $eventAgentPathMod = $eventAgentPathMod.replace('"',"")
                $eventAgentPathMod = $eventAgentPathMod.replace('"',"")
                $eventAgentPathMod = $eventAgentPathMod.replace(":","$")
                $agentUNC = "\\" + $filerHostname + "\" + $eventAgentPathMod
                $fileInfo = get-item -path $agentUNC
                $fileVersion = ($fileInfo.VersionInfo.FileVersion).Replace(",",".")
                echo " - Event Agent Version: $fileVersion"
            }
            catch {
                $fileVersion = "N/A"
            }

            try {
                echo " - Getting filewalk agent version"
                $FwAgentPath = (Get-WmiObject win32_service -ComputerName $filerHostname | ?{$_.name -eq "VrnsSvcFW"}).pathname
                #$FwAgentPathMod = $FwAgentPath.replace("\VrnsSvcFW.exe","")
                $FwAgentPathMod = $FwAgentPath.replace('"',"")
                $FwAgentPathMod = $FwAgentPathMod.replace('"',"")
                $FwAgentPathMod = $FwAgentPathMod.replace(":","$")
                $fwAgentUNC = "\\" + $filerHostname + "\" + $FwAgentPathMod
                $fwFileInfo = get-item -path $fwAgentUNC
                $fwFileVersion = ($fwFileInfo.VersionInfo.FileVersion).Replace(",",".")
                echo " - FW Agent Version: $fwFileVersion"
            }
            catch {
                $fwFileVersion = "N/A"
            }
        }
        else {
            $fileVersion = "N/A"
            $fwFileVersion = "N/A"
        }
        

    }
    else {
        echo " - $filerHostname is DOWN"
        $filerStatus = "DOWN"
    }

    Add-Content $commitLog "$filerHostname,$filerType,$filerOS,$filerStatus,$colName,$eventCollection,$fileVersion,$fwFileVersion,$IPAddress"



Clear-Variable filerHostname
Clear-Variable eventCollection
Clear-Variable filerType
Clear-Variable colID
Clear-Variable colName
Clear-Variable filerStatus
Clear-Variable fileVersion
Clear-Variable fwFileVersion
Clear-Variable filerOS
Clear-Variable IPAddress



}








echo "`nPress any key to close.."

#Stop-Transcript