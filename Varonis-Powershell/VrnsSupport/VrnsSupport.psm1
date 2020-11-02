##. .\Misc\UAC.ps1

Get-ChildItem -Recurse -Path . -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
Export-ModuleMember -Function Get-UAC, Set-UAC, Get-InstalledApps, Get-BlockedFiles, Open-Port
