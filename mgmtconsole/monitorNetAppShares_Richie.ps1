<#
    Tested on 6.3.185 and PowerShell 3

    Description:

        Adds a list of existing shares to a monitored 7mode NetApp
        
    Instructions:
        1. Update variables in the "UPDATE THESE" section
        2. Run


#>

# UPDATE THESE
$iduHostname = 'localhost'    #IDU hostname
$filerName = 'vserver1'    #NetApp vfiler hostname
$fwUser = 'jt\varonis'    #filewalk user
$fwPw = 'password1'    #Filewalk user password
$shareList = 'c:/users/jonathan/desktop/paths.csv'    #List of shares to add


#############################

Import-module VaronisManagement
Connect-IDU -Server $iduHostname
echo "Connected to IDU"


$shares = import-csv $shareList
$varCred = New-VaronisCredential -Username $fwUser -Password $fwPw
$filer = Get-FileServer -Name $filerName

# Track progress
$counter = 0
$totalShares = $shares.Count

echo "Adding shares to $filerName"
# Iterate through file servers and begin working on NetApps
foreach ($share in $shares) {

    

    $shareName = $share.ShareNames

    echo " - Adding $shareName"
        # Add the share to the file server object
        $newMonShare = Add-Share -ShareName $shareName -FileServer $filer -ErrorAction SilentlyContinue -ErrorVariable addShareError

        if ($addShareError) {
            $errorMessage = $addShareError[0]
            Write-Host -ForegroundColor Yellow " - $errorMessage"
        }
        else {
            $newMonShare.CollectEvents = $true
            #$newMonShare.Monitored = "Windows"
        }
        
    

    # Commit the changes in the Management Console
    
    
           
    
    clear-variable -ErrorAction SilentlyContinue shareName
}
echo "Updating Management Console" 
$setFiler = Set-FileServer -FileServer $filer
