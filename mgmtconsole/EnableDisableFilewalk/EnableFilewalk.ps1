<#
Description: 
    Enables/disables the filewalk and event collection for monitored SharePoint site collections.


Instructions:
    1. Fill out CSV file with list of sites
    2. Update $siteList variable below to the exact path of the CSV file
    3. Update $spServer with name of SP server
    3. Run script


#>

$siteList = "C:\Users\jonathan\Desktop\EnableDisableFilewalk\sites.csv" 	#Location of sites.csv
$spServer = "sp2013"    #SharePoint server



Import-Module VaronisManagement
Connect-IDU
"----------"



##############################################################################
####This stuff can be left alone

#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


$siteInfo = import-csv $siteList

$filer = Get-FileServer -Name $spServer

$siteInfo | foreach-object {
    $site = $_.site
    
    # loop through each monitored volume until we find one that matches what is in the csv
    $allVols = $filer.Volumes
    foreach ($vol in $allVols) {
        if ($vol.DisplayPath -eq $site) {

            "Enable filewalk on: " + $site
            $vol.Monitored = 2   #enable filewalk; Monitored: 1 - for windows, 2 - for sharepoint
            
        }
    }
    
}

"`nCommitting changes"
$job = Set-FileServer -FileServer $filer

" - Check Management Console for status"
