$json = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw | ConvertFrom-Json
$naYears = $json | Where-Object { $_.year -eq "N/A" -or [string]::IsNullOrWhiteSpace($_.year) }
Write-Host "Count of N/A years:" $naYears.Count

for ($i=0; $i -lt [Math]::Min(10, $json.Count); $i++) {
    $p = $json[$i]
    Write-Host "[$($p.id)] ($($p.year)) Title: $($p.title)"
    Write-Host "     Authors: $($p.authors)"
    Write-Host "     Journal: $($p.journal)"
    Write-Host "     DOI: $($p.doi)"
    Write-Host "---"
}
