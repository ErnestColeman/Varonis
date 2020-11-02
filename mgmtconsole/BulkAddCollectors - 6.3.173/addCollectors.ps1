<#
    Adds collectors to Management Console. All collector prereqs must be met before running this script.
    
    Tested on 6.3.173

#>

####UPDATE THESE VARIABLES
$colList = "E:\Scripts\BulkAddCollectors - 6.3.173\CollectorList.csv" 	# Location of CollectorList.csv
$workShareName = "VaronisWorkingShare"   # Working share name
$workDirUser = "JT\varonis"   # Domain account with Local admin on Collector and Read/Write permission on working share
$workDirPw = "password1"     


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

# Build credential objct
$varCred = New-VaronisCredential -Username $workDirUser -Password $workDirPw


# Import CollectorList CSV          
$colInfo = import-csv $colList

# Set up a counter to show progress
$serverCount = $colInfo | Measure-Object | Select-Object -expand count #.length #Used to display progress counter
$counter = 0



# Add collectors to MC.
$colinfo | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    try {
        Clear-Variable -ErrorAction SilentlyContinue -name colName, newCol, addCol
            

    }
    catch {

    }
    $counter++

    $colName = $_.hostname

    echo "[$counter/$serverCount]: Adding $colName"
    $newCol = New-Collector -ServerName $colName -WorkingShare $workShareName -ShareCredential $varCred -InstallationCredential $varCred
    $addCol = Add-Collector -Collector $newCol
    
}

"--------------------"

#disconnect from IDU
#"Disconnecting from IDU"
#disconnect-idu

"Complete - Check the Management Console for file server status"