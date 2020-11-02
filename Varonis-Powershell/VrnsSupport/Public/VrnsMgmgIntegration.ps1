Import-Module VaronisManagement

function Get-DSP{
    Connect-Idu | Out-Null
    return ((Get-IDU).ServicesHost | Out-String)
}