. ./Get-Booze.ps1

$d = Get-Booze
$d | ConvertTo-Json | Out-File -FilePath "./dump.json" -Force
$d | Export-Csv -Delimiter ';' -Path "./dump.csv" -Force
$d | ConvertTo-Html | Out-File -FilePath "./dump.html" -Force

git add 'dump.*'
git commit -m "automatic update"
git push