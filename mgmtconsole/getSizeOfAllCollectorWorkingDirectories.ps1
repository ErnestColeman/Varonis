# Get size of working directory from each collector

import-module VaronisManagement
connect-idu

$collector = Get-Collector

$collector | ForEach-Object {
    $colHost = $_.servername
    $colWorkDir = $_.fulldirectoryname

    $colWorkDir2 = $colWorkDir.replace("F:", "\\" + $colHost)
    #$colWorkDir2

    $dirSize = "{0:N2}" -f ((Get-ChildItem -path $colWorkDir2 -recurse | Measure-Object -property length -sum ).sum /1MB) + " MB"

    $colHost + " - " + $dirSize

}