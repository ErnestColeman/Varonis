<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

#Import-Module SqlPs

#Check that the script is being run as Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
"--------------------"
"--------------------"

#Automating Process of getting IDU Hostname, will write to console so it can be verified
$IDU = Get-Content -Path "C:\ProgramData\Varonis\DatAdvantage UI\ServerConnections.config" | Select-String "<ServerName>*" 
$IDU = $IDU -replace ('\<servername\>', "") -replace ('\<\/ServerName\>', "")
$IDU = $IDU.Trim()

if ($IDU[0].Length -gt 2) {
    $IDU = $IDU[0]
}
else {
    $IDU = $IDU
}

#If incorrect, user should enter correct name
$IDUServer = Read-Host "If IDU name is incorrect, please enter IDU Server name. If not, please press enter: $IDU"

#Check to see if input is null (User Pressed Enter)
if (!$IDUServer) {
}
#Replace what was grabbed from $IDU Variable and use what user typed
else {
    $IDU = $IDUServer
}

#Connect to IDU
Import-Module Varonis*
Connect-Idu $IDU

$jobs = @("DatAlert Rule Prepare", "DatAlert Scope Delivery", "DatAlert Mark Changes", "DatAlert Notify Probe/Collector on Changes", "DatAlert Rules Sync")
foreach ($job in $jobs) {

    $jid = Get-JobID -Name $job | Select-Object -ExpandProperty guid

    $execution = Start-Job -ID $jid
    write-host "Job Started - $job"

    #$jid = Get-JobID -Name 'DatAlert Rule Prepare' 
    $jobstatus = Get-LastJobExecution -ID $jid | Select-Object -ExpandProperty IsCompleted

    While ($jobstatus -ne $true ) {
        Start-Sleep 10  
        $jobstatus = Get-LastJobExecution -ID $jid | Select-Object -ExpandProperty IsCompleted
        write-host "    $job is still running"
    }

}
Write-Host "All jobs complete"