$fwcreds = New-Varoniscredential -username jt\varonis -password password1
$agentcreds = New-Varoniscredential -username jt\varonis -password password1                    
$wf = New-WindowsFileServer -name jtcol -FileWalkCredentials $fwcreds -ProbeId  1 -AgentCredentials $agentcreds


$fileServer = "jtcol"
$fwUser = "jt\varonis"
$fwPW = "password1"
$fwCreds = New-Varoniscredential -username $fwuser -password $fwpw
$probeID = 1
New-WindowsFileServer -name $fileserver -FileWalkCredentials New-Varoniscredential -username $fwuser -password $fwpw -ProbeId $probeID


$fwcreds = New-Varoniscredential -username varonis@jt.com -password password1
$wf = New-WindowsFileServer -name jtcol -FileWalkCredentials $fwcreds -ProbeId  1


New-VaronisCredential -Username [<String>] -Password [<String>]