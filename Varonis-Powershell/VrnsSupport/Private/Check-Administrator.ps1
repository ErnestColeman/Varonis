function Get-Administrator{
    If ( -not ( [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole(` [Security.Principal.WindowsBuiltInRole] "Administrator") ){
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        return $false
    } else {
        return $true
    }
}