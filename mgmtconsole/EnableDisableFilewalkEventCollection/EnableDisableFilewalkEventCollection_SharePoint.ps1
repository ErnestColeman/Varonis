<#
Description: 
    Enables/disables the filewalk and event collection for monitored SharePoint site collections.
    Tested on 6.0.112 and 6.2.53


Instructions:
    1. Fill out CSV file with necessary info. Column header descriptions are below.
    2. Update the $filerList variable below to the exact path of the CSV file
    3. Run script


Column descriptions:
    FilerName:        Hostname of existing server as defined in the Management Console 
                        pre-6.2.53: use just the hostname of the webapp. Omit http:// and https:// (ie. sp2013)
                        6.2.53+: use the full name as listed in the MC (ie. http://sp2013)

    Volume:           Monitored site collections as listed in the Management console (ie. /sites/site1)
                        If multiple site collections on the same webapp need to be updated with the same settings,
                        use a | delimiter (ie. /sites/site1|/sites/site2)
    
    EnableFilewalk:   Put an X in this column to enable the filewalk on the site collection

    EnableEvents:     Put an X in this column to enable event collection on the site collection.
  
    NOTE: If you put an X under EnableEvents AND leave EnableFilewalk blank, it will enable BOTH events and filewalk
        for the specified site collection. This is because filewalk must be enabled for event collection.


Expected script behavior:

    There are four possible scenarios:

    1. Filewalk on  / Events on
        - monitored=2 and collectEvents=true
    2. Filewalk on  / Events off
        - monitored=2 and collectEvents=false
    3. Filewalk off / Events on 
        - monitored=2 and collectEvents=true
    4. Filewalk off / Events off
        - monitored=0 and collectEvents=false
#>



Import-Module VaronisManagement
Connect-IDU
"----------"

$filerList = "C:\Users\jonathan\Desktop\EnableDisableFilewalkEventCollection\FilerVolumes.csv" 	#Location of filerList.csv

##############################################################################
####This stuff can be left alone

#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


$filerInfo = import-csv $filerList

$filerInfo | foreach-object {
    $hostname = $_.FilerName
    $volume = $_.Volume
    $enableFW = $_.EnableFilewalk
    $enableEvents = $_.EnableEvents

    $hostname

    # Split the volume string by | delimiter
    $splitVols = $volume.Split("|")
    #$splitVols
    
    #Scenario 1 and 3
    # If only event collection is checked, we'll also need to enable the filewalk
    if ((([string]::IsNullOrEmpty($enableFW) -and (![string]::IsNullOrEmpty($enableEvents)))) -or ((![string]::IsNullOrEmpty($enableFW) -and (![string]::IsNullOrEmpty($enableEvents))))) {
        #" - Filewalk on; Events on"
        $filer = Get-FileServer -Name $hostname
        $allVols = $filer.Volumes
        foreach ($vol in $allVols) {
            foreach ($sVol in $splitVols) {
                if ($vol.DisplayPath -eq $sVol) {

                    " - " + $vol.DisplayPath + " - Enable filewalk; Enable event collection"
                    $vol.Monitored = 2   #enable filewalk; Monitored: 1 - for windows, 2 - for sharepoint
                    $vol.CollectEvents = $true  #enable event collection
                 }
            }
        }
        $job = Set-FileServer -FileServer $filer
        " - Check Management Console for status"
        
    }    

    # Scenario 2
    elseif (![string]::IsNullOrEmpty($enableFW) -and ([string]::IsNullOrEmpty($enableEvents))) {
        #" - Filewalk on; Events off"
        $filer = Get-FileServer -Name $hostname
        $allVols = $filer.Volumes
        foreach ($vol in $allVols) {
            foreach ($sVol in $splitVols) {
                if ($vol.DisplayPath -eq $sVol) {

                    " - " + $vol.DisplayPath + " - Enable filewalk; Disable event collection"
                    $vol.Monitored = 2   #enable filewalk; Monitored: 1 - for windows, 2 - for sharepoint
                    $vol.CollectEvents = $false  #disable event collection
                 }
            }
        }
        $job = Set-FileServer -FileServer $filer
        " - Check Management Console for status"
        
    }

    # Scenario 4
    elseif (([string]::IsNullOrEmpty($enableFW) -and ([string]::IsNullOrEmpty($enableEvents)))) {
        #" - Filewalk off; Events off"
        $filer = Get-FileServer -Name $hostname
        $allVols = $filer.Volumes
        foreach ($vol in $allVols) {
            foreach ($sVol in $splitVols) {
                if ($vol.DisplayPath -eq $sVol) {

                    " - " + $vol.DisplayPath + " - Disable filewalk; Disable event collection"
                    $vol.Monitored = 0   #enable filewalk; Monitored: 1 - for windows, 2 - for sharepoint
                    $vol.CollectEvents = $false  #disable event collection
                 }
            }
        }
        $job = Set-FileServer -FileServer $filer
        " - Check Management Console for status"
        
    }
    else {
        Write-Warning "error"
    }
    
}


