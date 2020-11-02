Import-Module -Name SQLServer -DisableNameChecking

function Connect-SQL {
    param(
        [Parameter(Mandatory = $true)]$Path
    )
    Set-Location SQLSERVER:\SQL\$Path\Databases
}

function Get-CostThreshold {

    $Table = Invoke-Sqlcmd "SELECT value_in_use FROM sys.configurations WHERE description = 'cost threshold for parallelism'" -SuppressProviderContextWarning -As DataTables

    [string]$CostThreshold = $Table[0].Rows[0].value_in_use

    return $CostThreshold.Trim()
}

function Get-MaxDegree {

    $Table = Invoke-Sqlcmd "SELECT value_in_use FROM sys.configurations WHERE description like '%max%parallelism%'" -SuppressProviderContextWarning -As DataTables

    [string]$MaxDegree = $Table[0].Rows[0].value_in_use

    return $MaxDegree.Trim()
}

function Get-TempDBConfig {  
    $Table = Invoke-SQLCmd "SELECT  name AS FileName,
                                size*1.0/128 AS FileSizeInMB,
                                CASE max_size
                                    WHEN 0 THEN 'False'
                                    WHEN -1 THEN 'True'
                                    ELSE 'Log file grows to a maximum size of 2 TB.'
                                END As Autogrowth,
                                growth AS 'GrowthValue',
                                'GrowthIncrement' =
                                CASE
                                    WHEN growth = 0 THEN 'Fixed'
                                    WHEN growth > 0 AND is_percent_growth = 0
                                    THEN 'KB.'
                                    ELSE '%'
                                END
                            FROM tempdb.sys.database_files;" -SuppressProviderContextWarning -As DataTable
    [System.Collections.ArrayList]$TempDBObjects = @()

    for ($i = 0; $i -lt $Table.Rows.Count; $i++) {

        $TempDBItem = [PSCustomObject] @{
            Filename        = $Table.Rows[$i].Filename
            FileSizeInMB    = $Table.Rows[$i].FileSizeInMB
            AutoGrowth      = $Table.Rows[$i].AutoGrowth
            GrowthValue     = $Table.Rows[$i].GrowthValue
            GrowthIncrement = $Table.Rows[$i].GrowthIncrement
        }

        $TempDBObjects.Add($TempDBItem) | Out-Null
    }

    return $TempDBObjects                                    
}

function Get-TraceFlags{
    $Table = Invoke-Sqlcmd 'DBCC TRACESTATUS();' -SuppressProviderContextWarning -As DataTables

    [System.Collections.ArrayList]$TraceFlags = @()

    if ($Table){
        for ($i=0; $i -lt $Table.Rows.Count; $i++){

            $TraceFlag = [PSCustomObject] @{
                    Traceflag = $Table.Rows[$i].TraceFlag
                    Status = $Table.Rows[$i].Status
                    Global = $Table.Rows[$i].Global
                    Session = $Table.Rows[$i].Session
            }

            $TraceFlags.Add($TraceFlag) | Out-Null
        }
      }
    return $TraceFlags

}
function Get-SQLConfig {
    param(
        [Parameter(Mandatory = $true)]$Path
    )

    Connect-SQL -Path $Path

    Write-Host "Cost Threshold: " -NoNewline
    Get-CostThreshold

    Write-Host "Max Degree: " -NoNewline
    Get-MaxDegree
    Write-Host `r`n

    Write-Host "SQL Version:"
    Get-SQLInstance -ServerInstance $Path
    Write-Host `r`n
      
    Write-Host "TempDB Config:"
    Get-TempDBConfig | Format-Table

    Write-Host "TraceFlags:"
    Get-TraceFlags
}

function Get-SQLsysConfig {

	$Table = Invoke-Sqlcmd "select * from sys.configurations" -SuppressProviderContextWarning -As DataTables

	[System.Collections.ArrayList]$TempDBObjects = @()

	for ($i = 0; $i -lt $Table.Rows.Count; $i++) {

		$TempDBItem = [PSCustomObject] @{
			Name            = $Table.Rows[$i].name
			ValueInUse      = $Table.Rows[$i].value_in_use
			ConfigValue     = $Table.Rows[$i].Value
			ConfigID        = $Table.Rows[$i].configuration_id
			minimum         = $Table.Rows[$i].minimum
            Maximum         = $Table.Rows[$i].maximum
            Description     = $Table.Rows[$i].description
            IsDynamic       = $Table.Rows[$i].is_dynamic
            IsAdvanced      = $Table.Rows[$i].is_advanced
		}

		$TempDBObjects.Add($TempDBItem) | Out-Null
	}

	return $TempDBObjects
}

<#
SELECT
   (cpu_count / hyperthread_ratio) AS Number_of_PhysicalCPUs,
   CPU_Count AS Number_of_LogicalCPUs
FROM sys.dm_os_sys_info
#>