<#
    Tested on 6.3.185 and PowerShell 3

    NetApp and NetAppCM Only

    Description:

        Enumerates all monitored file servers from the database.Uses net view command to 
        get list of available shares on remote server, compares that list to what we are 
        currently monitoring, and monitors what is remaining. 

        You can filter out specific shares by adding them to the filteredShares array.
        C$ and ETC$ are filtered by default.


    Instructions:
        1. Enter IDU hostname in the "Connect-IDU -Server..." line
        2. Enter any additional filtered shares in the filteredShares array


#>

Import-module VaronisManagement
Connect-IDU -Server "localhost"

# Filtered shares
$filteredShares = @('C$','ETC$','admin$')

# Location of NetApp list
$filerList = 'E:\REPORTS\SYSTEM\Scripts\DiscoverUnmonitoredShares\netappFilers.csv'
$filers = import-csv $filerList
#$filers = @('vserver1')


# Get list of monitored filers
#$filers = get-fileserver
#$filers.displayName

# Track progress
$counter = 0
$totalFilers = $filers.Count




# Iterate through file servers and begin working on NetApps
$filers | ForEach-Object {
    clear-variable -ErrorAction SilentlyContinue filerHostname, availShares, netvShares, monCifsShares, unMonShares, compShares, monCifsShares
    
    $filerHostname = $_

    $filerInfo = Get-FileServer -Name $filerHostname
    
    
    
    $filerType = 'NetApp'

    $counter++
    
    # Skip servers that are not NetApp or NetAppCM
    if ($filerType -eq 'NetApp'){
        
        Write-host -ForegroundColor Green "[$counter/$totalFilers] - $filerType - $filerHostname"
        
        # Test ping
        if (Test-Connection $filerHostname -quiet -count 1) {
            
            Write-host -ForegroundColor Green " - $filerHostname is reachable"
          
                    
            # Get available shares. The displayed shares will not include $filteredShares or NFS exports
            echo " - Available CIFS shares:"
            $availShares = @()
            $newFiler = New-NetAppFileServer -Name $filerHostname -FileWalkCredentials $varCred -DiscoverShares All
            $newFiler.Volumes | ForEach-Object {
                $newShare = $_.Share
                $newShareProt = $_.ExposedProtocols
                $newSharePath = $_.Path

                if (($newShare -notin $filteredShares) -and ($newShareProt -ne 'NFS')){
                    echo " -- $newShare"
                    $availShares += "$newShare"
                }
            }
            
            # Get current monitored CIFS shares
            echo " - Monitored CIFS shares:"
            $monCifsShares = @()
            $monVols = $filerInfo.volumes
            foreach ($monVol in $monVols) {
                $monVolPath = $monVol.Path

                if ($monVol.ExposedProtocols -ne 'NFS'){
                    $monCifsShare = $monVol.share
                    
                    echo " -- $monCifsShare"
                    $monCifsShares += "$monCifsShare"
                }
            }

            
            # Get current UNmonitored shares
            echo " - Unmonitored CIFS shares:"
            $unMonShares = @()
            $compShares = Compare-Object -ReferenceObject $monCifsShares -DifferenceObject $availShares -PassThru
            $compShares | ForEach-Object {
                if ($monCifsShares -notcontains $_){
                    echo " -- $_"
                    $unMonShares += $_
                }
            }

            # Get total unmonitored shares
            $unMonShareCount = $unMonShares.count
            
            
            if ($unMonShareCount -gt 0) {
                # Monitor the unmonitored shares
            
                echo " - Adding $unMonShareCount new share(s)"
                foreach ($unMonShare in $unMonShares) {
                    echo " -- $unMonShare"
            
                    # Add the share to the file server object
                    $newMonShare = Add-Share -ShareName $unMonShare -FileServer $filerInfo
                    $newMonShare.CollectEvents = $true
                    #$newMonShare.Monitored = "Windows"
                } 

                # Commit the changes in the Management Console
                echo " - Updating Management Console" 
                $setFiler = Set-FileServer -FileServer $filerInfo
            }
            else {
                Write-host -ForegroundColor Yellow " - No new shares"
            }
            
            
        }
        else {
            Write-host -ForegroundColor Red " - $filerHostname is unreachable"

        }
        
    }
    else {
        echo "[$counter/$totalFilers] - $filerType - $filerHostname"
    }

    
}


