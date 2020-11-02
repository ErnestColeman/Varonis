function Set-PowerPlan {
    param(
        [Parameter(Mandatory = $true)]$Plan
    )

    try {
        $Plan = $Plan.toLower()
        $perf = powercfg -l | ForEach-Object {if($_.toLower().contains($Plan)) {$_.split()[3]}}
        $currentPlan = $(powercfg -getactivescheme).split()[3]

        if ($currentPlan -ne $perf) {
            powercfg -setactive $perf
        }
    } catch {
        Write-Warning -Message "Unabled to set power plan to $Plan"
    }
    Get-ActivePowerPlan
}

function Get-ActivePowerPlan{
    $PowerPlan = powercfg /GETACTIVESCHEME
    $regex = [regex]"\((.*)\)"
    
    $PowerPlan = [regex]::match($PowerPlan, $regex).Groups[1]
    return $PowerPlan.Value
}
