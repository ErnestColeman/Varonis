$sql = Import-Csv -Path "$path"

$live = Import-Csv -Path "$path"

Compare-Object $sql $live -property GPO | Export-Csv -path $path -notypeinformation
