$service = Get-Service -Name Spooler -ErrorAction SilentlyContinue

if ($service.Length -gt 0) {

    Write-Host "Service Found"
}
else {
    Write-Host "Service Not found"
}
