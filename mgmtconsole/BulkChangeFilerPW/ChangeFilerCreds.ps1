$filer = 'jtcifs'
$agentCred = New-VaronisCredential -username jt\jonathan -password password1
Set-FileServer -FileServer] $filer -AgentCredential $agentCred