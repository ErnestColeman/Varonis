<#
    Tested on 6.3.185 and PowerShell 5

    Description:

        Adds probe proxies to MC. 
        Works with both DS and NetApp proxies

#>
$dateStamp = get-date -Format yyyMMddHHMM


####UPDATE THESE VARIABLES
$proxyList = "E:\Scripts\BulkAddProxy\proxyList.csv" 	# Location of proxy list
$transcriptLog = "E:\Scripts\BulkAddProxy\BulkAddProxy-$dateStamp.txt"  # Location of transcript file
$varUser = "JT\varonis"   # Domain account with Local admin on proxy servers
$varPw = "password1"     
$proxyType = "ProxyAdEventLogRpc" # Options: DS - ProxyAdEventLogRpc; NetApp - ProxyNtap

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


Start-Transcript -Path $transcriptLog

Import-Module VaronisManagement
Connect-Idu

# Build credential objct
$varCred = New-VaronisCredential -Username $varUser -Password $varPw


# Import CollectorList CSV          
$proxyInfo = import-csv $proxyList

# Set up a counter to show progress
$proxyCount = $proxyInfo | Measure-Object | Select-Object -expand count 
$counter = 0



# Add collectors to MC.
$proxyInfo | foreach-object {
    
    #clear all the temp variables from the CSV were using in the loop before running each time
    try {
        Clear-Variable -ErrorAction SilentlyContinue -name proxyName, addProxy
            

    }
    catch {

    }
    $counter++

    $proxyName = $_.hostname

    echo "[$counter/$proxyCount]: Adding $proxyName as $proxyType"
    $addProxy = Add-ProbeProxy -VaronisCredentials $varCred -Name $proxyName -Protocol $proxyType

    
}

"--------------------"

#disconnect from IDU
"Disconnecting from IDU"
disconnect-idu

"Complete - Check the Management Console for file server status"

Stop-Transcript