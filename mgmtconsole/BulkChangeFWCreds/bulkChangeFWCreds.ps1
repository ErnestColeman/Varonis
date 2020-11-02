$filerList = "C:\Users\jonathan.jt\Desktop\bulkChangeFWCreds\bulkChangeFWCreds.csv"
#get Varonis stuff ready
Import-Module -Name 'VaronisManagement'
Connect-Idu
$filerInfo | foreach-object {
    $hostname = $_.hostname
    $user = $_.FWUser
    $pw = $_.FWPassword
    #update pw
    $f = get-fileserver –name $hostname
    $f.FileWalkUsername = $user
    $f.FileWalkPassword = $pw
    Set-FileServer $f
    }