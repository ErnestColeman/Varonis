# Version: 	0.5
# Date:		2019-01-30
# File Name:	Get-InstalledApps
# Author:	TylerJWhit
# Notes:	
#		The following commands may be of help:
#		
#		Run against every computer in domain. 
#		Get-ADComputer -Filter * | Select-Object -ExpandProperty Name | Get-InstalledApps
#		
#		Run against CSV (replace path with location of file and ensure A1 says 'computername':
# 		Get-InstalledApps -computers (Import-Csv -Path C:\Computers.csv | Select-Object -ExpandProperty computername)
#		
#		Run against computers listed in command:
#		Get-InstalledApps -computers HOSTNAMEA,HOSTNAMEB

function Get-InstalledApps {
    
    Param (

    [CmdletBinding()]
	
    [Parameter(ValueFromPipeline=$true)]

    [Alias('name')] # Helps with 'Select-Object -ExpandProperty Name'
    
    [string[]]$computers = $env:COMPUTERNAME
    
    )
    process {
        foreach($computer in $computers){
        
            write-verbose -verbose -message "`nStarting scan on $computer"
            
            Invoke-Command -Computername $computer -ErrorAction SilentlyContinue -ErrorVariable InvokeError -Scriptblock  {
        
                $installPaths = @('HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
            
                Get-ChildItem -Path $installPaths | Get-ItemProperty | Sort-Object -Property DisplayName | Select-Object -Property DisplayName, DisplayVersion, Publisher, UninstallString, Version
                
            }
        
            if ($invokeerror){
        
                    Write-Warning "Could not communicate with $computer"
    
            } # if ($invokeerror)
        } # foreach($computer in $computers)
    } # process
} # function Get-InstalledApps