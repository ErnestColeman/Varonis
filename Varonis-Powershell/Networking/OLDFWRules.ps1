function Choose-SourceDest {
 
 
    [CmdletBinding()]
     
    param
     
    (
     
    [Parameter(Mandatory=$true, Position=0)]
    $SourceType,
     
    [Parameter(Mandatory=$true, Position=1)]
    $DestinationType
     
    )
     
    switch ( $SourceType.ToLower() )
    {
        { 'idu', 'probe' -contains $_ } 
        {
            switch ( $DestinationType.ToLower() )
            {
                directoryservices
                {
                    $Port=53,88,123,135,139,389,445,636,3268,3269
                }
                probe
                {
                    $Port=135,2907,4972,4974,8000,9111,45678
                }
                collector
                {
                    $Port=135,2907,4972,4974,8000,9111,45678
                }
                winfiler
                {
                    $Port=4972,4974,445
                }
     
    
            }
     
        }
        Collector
        {
            switch ( $DestinationType.ToLower() )
            {
                directoryservices
                {
                    $Port=53,88,123,135,139,389,445,636,3268,3269
                }
                probe
                {
                    $Port=135,2907,4972,4974,8000,9111,45678
                }
                collector
                {
                    $Port=135,2907,4972,4974,8000,9111,45678
                }
                winfiler
                {
                    $Port=4972,4974,445
                }
     
    
            }
     
        }
     
    }
     
    return $Port
     
    }
     
    function Test-OpenPort {
     
    <# 
     
    .SYNOPSIS
    Test-OpenPort is an advanced Powershell function. Test-OpenPort acts like a port scanner. 
     
    .DESCRIPTION
    Uses Test-NetConnection. Define multiple targets and multiple ports. 
     
    .PARAMETER
    Target
    Define the target by hostname or IP-Address. Separate them by comma. Default: localhost 
     
    .PARAMETER
    Port
    Mandatory. Define the TCP port. Separate them by comma. 
     
    .EXAMPLE
    Test-OpenPort -Target sid-500.com,cnn.com,10.0.0.1 -Port 80,443 
     
    .LINK
    None. 
     
    .INPUTS
    None. 
     
    .OUTPUTS
    None.
     
    #>
     
    [CmdletBinding()]
     
    param
     
    (
    [Parameter(Mandatory=$true, Position=0, Helpmessage = 'Enter the hostname of the machine you want to test connectivity to.')]
    $Target='localhost',
     
    [Parameter(Mandatory=$false, Position=1, Helpmessage = 'Enter Port Numbers. Separate them by comma.')]
    $PortNums,
     
    [Parameter(Mandatory=$true, Position=2, Helpmessage = 'Enter source type (IDU, Probe, Collector).')]
    $SourceType,
     
    [Parameter(Mandatory=$true, Position=3, Helpmessage = 'Enter destination type (IDU, Probe, Collector, WinFiler, DirectoryServices).')]
    $DestinationType
     
    )
     
    $PortNums= Choose-SourceDest -SourceType $SourceType -DestinationType $DestinationType
    #$testPorts 
     
    $Ports = @{
    Port_53 = 'DNS'
    Port_88 = 'Kerberos'
    Port_123 = 'NTP'
    Port_135 = 'RPC-EPMAP'
    Port_139 = 'NetBIOS-SSN'
    Port_389 = 'LDAP/LDAPS'
    Port_445 = 'SMB'
    Port_636 = 'LDAP/LDAPS'
    Port_2907 = 'DCF Monitor'
    Port_3268 = 'MSFT-GC/MSFT-GC-SSL'
    Port_3269 = 'MSFT-GC/MSFT-GC-SSL'
    Port_4972 = 'Events'
    Port_4974 = 'FileWalk (While Active)'
    Port_8000 = 'Varonis Communication (IDU Managemnet)'
    Port_9111 = 'Varonis Communication (Delivery System)'
    Port_45678 = 'DCF File Analysis'
    }
     
    $result=@()
     
    foreach ($t in $Target)
     
    {
     
    foreach ($p in $PortNums)
     
    {
     
    $a=Test-NetConnection -ComputerName $t -Port $p -WarningAction SilentlyContinue
     
    $result+=New-Object -TypeName PSObject -Property ([ordered]@{
    'Target'=$a.ComputerName;
    'RemoteAddress'=$a.RemoteAddress;
    'Port'=$a.RemotePort;
    'Status'=$a.tcpTestSucceeded
     
     
    })
     
     
    if($a.tcpTestSucceeded -eq 0){ 
        $curPort = 'Port_'+$a.RemotePort
        $result+= "                      " + $curPort + " is used for/by " + $ports[$curPort] 
    }
    }
     
    }
     
    Write-Output $result
     
    }
     
    #Test-OpenPort -Target CharlieDC -Port 53,88,123,135,139,389,445,636,3268,3269
     
    <# 
    53 - DNS
    88 - Kerberos
    123 - NTP
    135 - RPC-EPMAP
    139 - NetBIOS-SSN
    389 - LDAP/LDAPS
    445 - SMB
    636 - LDAP/LDAPS
    3268 - MSFT-GC/MSFT-GC-SSL
    3269 - MSFT-GC/MSFT-GC-SSL
     
    Ports by version - \\varonis.com\global\Product\Technical Publications 
     
    #>
     
    
    function Test-ThemAll {
    Import-Module VaronisManagement
    Connect-IDU
    Get-Command -Module VaronisManagement
     
    #Get all the components into variables
    $IDU = (Get-IDU).ServicesHost
    $Probes = (get-probe).ServicesHost
    $Collectors = (get-collector).ServerName
    $Allfilers = Get-FileServer
    $WinFilers = $Allfilers | Where-Object {$_.FilerType -eq 'Windows'} | Select-Object -ExpandProperty ServerName
    $UnixFilers = $Allfilers | Where-Object {$_.FilerType -eq 'Unix'} | Select-Object -ExpandProperty ServerName
    $EMCFilers = $Allfilers | Where-Object {$_.FilerType -eq 'EMC'} | Select-Object -ExpandProperty ServerName
    $NetAppFilers = $Allfilers | Where-Object {$_.FilerType -eq 'NetApp'} | Select-Object -ExpandProperty ServerName
    $NetAppCMFilers = $Allfilers | Where-Object {$_.FilerType -eq 'NetAppCM'} | Select-Object -ExpandProperty ServerName
    $UnixSMBFilers = $Allfilers | Where-Object {$_.FilerType -eq 'UnixSMB'} | Select-Object -ExpandProperty ServerName
    $ExchangeFilers = $Allfilers | Where-Object {$_.FilerType -eq 'Exchange'} | Select-Object -ExpandProperty ServerName
     
    
    #Test to see what we need to validate, and try the ports. 
    if($IDU -eq $Probes) {
        Write-Output "Combined IDU/Probe, skipping port checks"
        }
    else {
        Write-Output "Checking connections between IDU and Probes"
        Test-OpenPort -Target $Probes -SourceType IDU -DestinationType Probe
    }
     
    if(! $Collectors) {
        Write-Output "No Collectors, skipping"
        }
    else {
        Write-Output "Checking connections between IDU and Collector(s)"
        Test-OpenPort -Target $Collectors -SourceType IDU -DestinationType Collector
        }
     
    }