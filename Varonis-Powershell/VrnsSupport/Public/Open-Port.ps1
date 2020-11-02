function Open-Port{
    
    param (
    [Parameter(mandatory=$true)]
    [int]$Port
    )

    ([System.Net.Sockets.TcpListener]$Port).Start()

    Write-Host 'Listening on port ' + $Port
    Read-Host 'Press any key to continue'
}