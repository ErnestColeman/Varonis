New-Item -Path c:\Results -ItemType directory

#-- Pull the version of the VrnsCifsQueue.exe file and write to Version.txt file
wmic datafile where name='C:\\Program Files\\Varonis\\WinAgent\\VrnsCifsQueue.exe' get version > C:\results\Version.txt

#-- Run GPResult and output results to gpresult.txt
gpresult /r > C:\Results\gpresult.txt

#-- Run auditpol utility to pull pertinent Audit Policy values and write them to auditpol.txt 
auditpol /get /subcategory:"Directory Service Changes" | Select-Object -last 2 | Select-Object -first 1 >> C:\results\auditpol.txt 
auditpol /get /subcategory:"Computer Account Management" | Select-Object -last 2 | Select-Object -first 1 >> C:\results\auditpol.txt 
auditpol /get /subcategory:"User Account Management" | Select-Object -last 2 | Select-Object -first 1 >> C:\results\auditpol.txt