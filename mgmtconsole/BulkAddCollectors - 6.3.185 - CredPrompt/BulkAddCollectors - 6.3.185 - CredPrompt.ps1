<#
    Adds collectors to Management Console. All collector prereqs must be met before running this script.
    
    Tested on 6.3.185

    Instructions:
    1. Update '$colList' and '$workShareName' variables below:
        - colList: csv file containing a list of collector hostnames
        - workShareName: Name of existing shared folder on each collector to be used
            as the Varonis Working Share
    2. Run the script as Administrator
    3. The script will prompt for Working Share and Collector Host credentials
    4. View the Management Console for status

#>

####UPDATE THESE VARIABLES
$colList = "C:\Users\jonathan\Desktop\BulkAddCollectors - 6.3.173\CollectorList.csv" 	# Location of CollectorList.csv
$workShareName = "VaronisWorkingShare"   # Working share name (must be the same on all collectors)


##############################################################################
####This stuff can be left alone

#check that the script is being run as an Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
"--------------------"
"--------------------"
Import-Module VaronisManagement
Connect-Idu

# Build credential objcts
Write-Host -ForegroundColor Yellow "Enter Collector Working Share Credentials"
$workingShareCred = New-VaronisCredential

Write-Host -ForegroundColor Yellow "Enter Collector Host Credentials"
$hostCred = New-VaronisCredential


# Import CollectorList CSV          
$colInfo = import-csv $colList

# Set up a counter to show progress
$serverCount = $colInfo | Measure-Object | Select-Object -expand count #.length #Used to display progress counter
$counter = 0



# Add collectors to MC.
$colinfo | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    Clear-Variable -ErrorAction SilentlyContinue -name colName, newCol, addCol
    
    $counter++

    $colName = $_.hostname

    echo "[$counter/$serverCount]: Adding $colName"
    $newCol = New-Collector -ServerName $colName -WorkingShare $workShareName -ShareCredential $workingShareCred -InstallationCredential $hostCred
    $addCol = Add-Collector -Collector $newCol
    
}

"--------------------"

#disconnect from IDU
#"Disconnecting from IDU"
disconnect-idu

"Complete - Check the Management Console for file server status"