# Author: Gal Szkolnik
# Company: Varonis
# KB 000009363
# Straightforward run: 
# .\EnumFilers.ps1 | Format-Table
# Specific formatting:
# .\EnumFilers.ps1 | Format-Table @{L="Hostname";W=30;E={$_.Hostname}},@{L="FileWalk Agent";W=10;E={$_.FWAgentVer}},@{L="Audit Agent";W=10;E={$_.AuditAgentVer}},@{L="Errors";W=100;E={$_.Errors}}
# List only the Windows servers where either or both agents are missing:
# .\EnumFilers.ps1 -ServerType Windows | Where-Object { $_.FWAgentVer -eq $null -or $_.AuditAgentVer -eq $null }
#
#


[CmdletBinding()]param(
[ValidateSet("SharePoint","Emc","NetAppCM","NetApp","SharePointOnline","Exchange","Unix","Windows","ExchangeOnline","Nasuni")]
[String[]]$ServerType = @("Windows","SharePoint","Exchange")
)

function Get-RemoteServiceFileInfo {
[CmdletBinding()]param(
    [Parameter(ParameterSetName="ServiceName",Mandatory)]
    $ServiceName,
    [Parameter(ParameterSetName="ServiceName",Mandatory)]
    $ComputerName,
    [Parameter(ParameterSetName="Service",Mandatory)]
    $Service
)
    if( $ServiceName ) {
        $Service = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_Service -Filter "Name = '$ServiceName'"
        if( -not $Service ) { return; $null }
    }

    $local:Path = [System.IO.DirectoryInfo]($Service.PathName.Trim('"'))
    $local:query = "
        SELECT *
            FROM CIM_DataFile
            WHERE Drive     = '$($Path.Root.FullName.Substring(0,2))'
              AND Path      = '$($Path.Parent.FullName.Substring($Path.Root.FullName.Length-1) -replace '\\','\\')\\'
              AND FileName  = '$($Path.BaseName.Substring(0,$Path.BaseName.Length - $Path.Extension.Length))'
              AND Extension = '$($Path.Extension.Substring(1))'
        "
    Get-CimInstance -ComputerName $Service.SystemName -Query $query

            # $query | Out-Host

        }

        

        Import-Module VaronisManagement

        Connect-Idu | Out-Null

        

        $local:results = @()

        $local:allFilers = Get-FileServer

        $local:filers = $allFilers | Where-Object { -not $ServerType -or $_.FilerType -in $ServerType }

        

        foreach( $local:filer in $filers ) {

            $local:errors = @()

            $local:e1 = $null

            $local:e2 = $null

        

            $local:data = [PSCustomObject] @{

                Hostname = $filer.ServerName

                ServerType = $filer.FilerType

                FWAgentVer = "Error"

                AuditAgentVer = "Error"

                Errors = @()

            }

        

            try {

                $data.FWAgentVer = Get-RemoteServiceFileInfo -ServiceName 'VrnsSvcFW' -ComputerName $filer.ServerName -ErrorAction Stop | Select-Object -ExpandProperty Version

            } catch {

                $data.Errors += $_

            }

        

            try {

                $data.AuditAgentVer = Get-RemoteServiceFileInfo -ServiceName 'VrnsCifsQueue' -ComputerName $filer.ServerName -ErrorAction Stop | Select-Object -ExpandProperty Version

            } catch {

                $data.Errors += $_

            }

        

            $data

        }

        

        Disconnect-Idu | Out-Null 