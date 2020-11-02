function Add-FWRule {
    param (
        [string]    $Ports,
        [string]    $Type = '',
        [bool]      $isTCP = $true,
        [string]    $Program
    )
    New-NetFirewallRule -DisplayName 'Varonis - ' $Type -Direction Inbound -Action Allow -Profile Domain -Port $Ports -Protocol $isTCP
}

function Add-CollectorFW{

    $portlist = 135,139,15671,15672,1573,2907,445,45678,47778,4972,514,5671,5672,60777,60778,8000,9111

    Add-FWRule -Type 'Collector' -Ports $portlist

}