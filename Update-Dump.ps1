git -C $PSScriptRoot pull

. $PSScriptRoot/Get-Booze.ps1


$d = Get-Booze | Where-Object AlcoholPercentage -GT 0 | Sort-Object Source,ProductNumber
$d | ConvertTo-Json | Out-File -FilePath "$PSScriptRoot/dump.json" -Force
$d | Export-Csv -Delimiter ';' -Path "$PSScriptRoot/dump.csv" -Force
$d | ConvertTo-Html | Out-File -FilePath "$PSScriptRoot/dump.html" -Force

git -C $PSScriptRoot add 'dump.*'
git -C $PSScriptRoot commit -m "automatic update"
git -C $PSScriptRoot push