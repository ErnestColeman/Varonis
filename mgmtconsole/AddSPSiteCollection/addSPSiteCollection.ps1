<#  Adds new site collections to an existing monitored SharePoint webapp

    Patch #473357 is required for pre-6.2 DatAdvantage

    Instructions:
    1. Specify SharePoint server name. This is likely the hostname of the 
        frontend server used when initially monitoring SharePoint.
    2. Set event collection and filewalk variables.



#>

# Set some variables
$spServerName = "sp2013"
$eventCollection = $false     # Enable/disable event collection: $True/$False
$fileWalk = 2     # Enable/disable filewalk: 2=True, 0=False
$siteList = "C:\Users\jonathan\Desktop\sites.csv" 	#Location of sites.csv

Import-Module VaronisManagement
Connect-IDU

# Get the file server object
$filer = get-fileserver -Name $spServerName

$siteInfo = import-csv $siteList

$siteInfo | foreach-object {
    $site = $_.site

    echo "Adding $site"
    # Add new site collection as volume
    $vol1 = New-SiteCollection -Path $site

    # Set event collection and filewalk
    $vol1.CollectEvents = $eventCollection
    $vol1.Monitored = $fileWalk
    $newVol = Add-Volume -Volumes $vol1 -FileServer $filer

}

echo "Saving changes.."
# Add it to the Management Console queue
$saveVol = Set-FileServer -FileServer $filer 

echo "Check Management Console for status"

