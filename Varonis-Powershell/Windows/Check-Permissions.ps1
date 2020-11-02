$path = "C:\Program Files (x86)\Minecraft"

$folder = Get-Acl -Path $path

$file = Get-Acl -Path "$path\updateLog.txt"

#Write-Host -Object $folder

#Write-Host -Object $file

Compare-Object -ReferenceObject $folder -DifferenceObject $file -IncludeEqual

if (Compare-Object -ReferenceObject $folder -DifferenceObject $file) {
    'not equal'
}
else {
    'equal'
}