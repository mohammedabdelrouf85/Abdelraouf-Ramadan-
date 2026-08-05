$html = Get-Content -Path 'd:\MY PC\Coding\Portfolio\index.html' -Raw
$html = $html -replace '126 Papers', '117 Papers'
$html = $html -replace '126 Publications', '117 Publications'
$html = $html -replace '126 Research Papers', '117 Research Papers'
$html = $html -replace '126 peer-reviewed', '117 peer-reviewed'
$html = $html -replace '126 of 126', '117 of 117'
$html = $html -replace '\(126\)', '(117)'
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Portfolio\index.html', $html, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\index.html', $html, [System.Text.Encoding]::UTF8)
Write-Host "Updated index.html count tags to 117!"
