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
        1. Enter IDU hostname in the "Connect-IDU -Server..." line (around line 23)
        2. Update path to NetApp hostname csv list $filerList (around line 30)
        3. Optional: To run the script and not commit, comment the $newMonShare and $setFiler variables (around lines 127 and 134)


#>

Import-module VaronisManagement
Connect-IDU -Server "localhost"

# Filtered shares
$filteredShares = @('C$','ETC$','admin$')

# Location of NetApp list
#$filerList = 'E:\REPORTS\SYSTEM\Scripts\DiscoverUnmonitoredShares\netappFilers.csv'
#$filers = import-csv $filerList
$filers = @('BREDSNTP002')

# Get list of monitored filers
#$filers = get-fileserver -Name 'us1dsntv006'
#$filers.displayName

# Track progress
$counter = 0
$totalFilers = $filers.Count

# Iterate through file servers and begin working on NetApps
$filers | ForEach-Object {
    
    try {
        clear-variable -ErorrAction SilentlyContinue filerHostname, availShares, netvShares, monCifsShares, unMonShares

    }
    catch {

    }
    
    #$filerHostname = $ntap.hostname
    $filerHostname = $_

    $filerType = 'NetApp'

    $counter++
    
    # Skip servers that are not NetApp or NetAppCM
    if (($filerType -eq 'NetApp') -or ($filerType -eq 'NetAppCM')){
        
        Write-host -ForegroundColor Green "[$counter/$totalFilers] - $filerType - $filerHostname"
        
        # Test ping
        if (Test-Connection $filerHostname -quiet -count 1) {
            
            Write-host -ForegroundColor Green " - $filerHostname is reachable"

            $filer = get-fileserver -Name $filerHostname
          
            #$ntapHost = $filer.DisplayName
        
            # Get available shares using net view, even hidden shares
            $netvSharesInfo = net view $filerHostname /all | Select-Object -Skip  7 |
                ForEach-Object -Process {[regex]::replace($_.trim(),'\s+',' ')} |
                ConvertFrom-Csv -delimiter ' ' -Header 'sharename', 'type', 'usedas', 'comment' | 
                Where-Object {$_.type -eq 'Disk'} | 
                Select-Object -Property sharename
            $netvShares = $netvSharesInfo.sharename
            
            echo " - Available CIFS shares:"
            $availShares = @()
            # Iterated through all shares and add non-filtered shares to the availShares array
            foreach ($netvShare in $netvShares){
                if ($netvShare -notin $filteredShares){
                    echo " -- $netvShare"
                    $availShares += $netvShare
                }
            }

            # Get current monitored shares
            echo " - Monitored CIFS shares:"
            $monCifsShares = @()
            $monVols = $filer.volumes
            foreach ($monVol in $monVols) {
                
                if ($monVol.ExposedProtocols -ne 'NFS'){
                    $monCifsShare = $monVol.share
                    
                    echo " -- $monCifsShare"
                    $monCifsShares += $monCifsShare
                }
            }

            # Get current UNmonitored shares
            echo " - Unmonitored CIFS shares:"

            $unMonShares = Compare-Object -ReferenceObject $monCifsShares -DifferenceObject $availShares -PassThru
            foreach ($unMonShare in $unMonShares) {
                echo " -- $unMonShare"
            
            }

            # Get total unmonitored shares
            $unMonShareCount = $unMonShares.count


            if ($unMonShareCount -gt 0) {
                # Monitor the unmonitored shares
            
                echo " - Adding $unMonShareCount new share(s)"
                foreach ($unMonShare in $unMonShares) {
                    echo " -- $unMonShare"
            
                    # Add the share to the file server object
                    $newMonShare = Add-Share -ShareName $unMonShare -FileServer $filer # Comment these three lines to not add the share objects
                    #$newMonShare.CollectEvents = $false # and this one
                    #$newMonShare.Monitored = $true # and this one
                } 

                # Commit the changes in the Management Console
                echo " - Updating Management Console" 
                #$setFiler = Set-FileServer -FileServer $filer #THIS ACTUALLY COMMITS THE CHANGES IN THE MC
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




# ITA_VER_PH_AFFREG