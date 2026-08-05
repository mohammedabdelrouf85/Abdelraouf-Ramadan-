$jsonText = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw
$papers = $jsonText | ConvertFrom-Json
Write-Host "Total Loaded Papers: $($papers.Count)"
Write-Host "First Paper: $($papers[0].title) ($($papers[0].year))"
Write-Host "Last Paper: $($papers[-1].title) ($($papers[-1].year))"
