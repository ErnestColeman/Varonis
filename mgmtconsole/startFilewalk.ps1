# Starts filewalk job for specified file server.
# 
# Accepts the following arguments:
# - IDU (not mandatory, will default to localhost)
# - hostname (mandatory, must match servername as defined in Management Console)
# 
# Sample syntax:
# startFilewalk.ps1 -hostname WinApp1
#
# Tested on 6.2.35

param (
    [Parameter()][string]$IDU = "localhost",
    [Parameter(Mandatory=$true)][string]$hostname
)

Connect-Idu -Server $IDU

$jname = "Filewalk " + $hostname 
$jid = Get-jobid -Name $jname


$fwJob = Start-Job -ID $jid
$fwJobStatus = Get-JobState -CommandID $fwJob

if ($fwJobStatus.State -eq "Succeed") {
    "Filewalk started"
}
else {
    $fwJobStatus.message
}

break