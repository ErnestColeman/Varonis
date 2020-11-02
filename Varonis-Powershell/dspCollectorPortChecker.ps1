$DSP = Get-IDU | Select-Object -ExpandProperty ServicesHost
$Ports   =  "135",
            "9111",
            "138",
            "139",
            "137",
            "8000",
            "5671",
            "5672",
            "15671",
            "15672",
            "60777",
            "60778",
            "443",
            "80",
            "445"
 
$Collector = Get-FileServer | select -ExpandProperty CollectorName
$Results = @()
$Results = Invoke-Command $DSP {param($Collector,$Ports)
                $Object = New-Object PSCustomObject
                $Object | Add-Member -MemberType NoteProperty -Name "DSP" -Value $env:COMPUTERNAME
                $Object | Add-Member -MemberType NoteProperty -Name "Collector" -Value $Collector
                    Foreach ($P in $Ports){
                        $PortCheck = (Test-NetConnection -Port $p -ComputerName $Collector ).TcpTestSucceeded
                        If($PortCheck -notmatch "True|False"){$PortCheck = "ERROR"}
                        $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($PortCheck)"
                    }
                $Object
           } -ArgumentList $Collector,$Ports | select * -ExcludeProperty runspaceid, pscomputername
 
#To see a grid, in GUI form, uncomment below.           
#$Results | Out-GridView -Title "Testing Ports"
 
$Results | Format-Table -AutoSize

$Results | Export-Csv -Path c:\results.csv -NoTypeInformation