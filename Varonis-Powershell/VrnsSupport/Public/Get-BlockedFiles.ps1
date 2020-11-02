function Get-BlockedFiles {
    Param (
        [string] $cwd = $PSScriptRoot
    )
    Write-Host $cwd
    if (Test-Path $cwd){
        Get-Item $cwd -stream "Zone.Identifier" -ErrorAction SilentlyContinue | Select-Object FileName
    } else{
        Write-Host 'Not a valid path'
    }
}