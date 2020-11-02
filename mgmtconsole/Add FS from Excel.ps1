
Import-module varonismanagement
Connect-IDU
$VaronisSVCAcct = Read-Host "Please,enter the account to login in the form "Domain\samaccountname" "
$VaronisSVCPass = Read-Host -Prompt "Enter Password for the Varonis Service account" -AsSecureString
$pscredential = New-Object System.Management.Automation.PSCredential($VaronisSVCAcct,$VaronisSVCPass)
$csv = import-csv C:\temp\book2.csv
$csv.gettype().Fullname
foreach($row in $csv)
{
$col = $row.Collectors # collector selected for the Server to monitor
$Server = $row.Servers
$collector = get-collector -name $col | select-object -expandproperty CollectorId
$collectorID = get-collector -legacyid $collector
$probe = get-probe -name 'bridu1' | select-object -ExpandProperty Probeid
$Creds= new-varoniscredential -Credential $pscredential
$addservers= new-windowsfileserver -name $Server -filewalkcredentials $Creds -Probe $probe -Collector $collectorid
$addservers.config.all.SharesAutoDetectionFashion ="detectmonitorandnotify, notifyonce"
$addservers.config.skipfilewalkchange = $true # filewalk agent
$addservers.config.IgnoreDriverChanges = $true #event collection Agent
$addservers.CollectEvents = $true
add-fileserver -fileserver $addservers -autofillvolumes -force -CollectorCredential $Creds
}
Sleep -Seconds 5
$varonisSVCPass = ""