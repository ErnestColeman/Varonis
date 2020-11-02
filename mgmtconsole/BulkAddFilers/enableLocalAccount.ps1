#enable collect info regarding local accounts on all servers
#Location of filerList csv
$filerList = "C:\Users\jonathan.jt\Desktop\bulkAddFilers\bulkAddFilers.csv"
#get Varonis stuff ready
Import-Module -Name 'VaronisManagement'
Connect-Idu
$filerInfo | foreach-object {
    #general variables from csv
    $hostname = $_.hostname
    #enable the setting
    $f = get-fileserver –name $hostname
    $f.Config.All.CollectLocalAccountsInfo = 1
    #$f.Config.CollectLocalAccountsInfo
    Set-FileServer $f
    }