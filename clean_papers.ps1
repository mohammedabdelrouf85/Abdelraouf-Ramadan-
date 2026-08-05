$jsonText = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw
$papers = $jsonText | ConvertFrom-Json

Write-Host "Total Papers: $($papers.Count)"
$naCount = 0

foreach ($p in $papers) {
    if ($p.year -eq "N/A" -or [string]::IsNullOrWhiteSpace($p.year)) {
        $naCount++
        # Try finding year in raw string
        if ($p.raw -match '\b(19\d\d|20\d\d)\b') {
            $p.year = $matches[1]
        }
    }

    # Clean up raw text in title
    $t = $p.title
    
    # If title has author prefix like "Abdelraouf, R. E., "
    if ($t -match '^(Abdelraouf[^\.]*\.|\w+,\s+[A-Z\.\s]+)\s*(.*)$' -and $t.Length -gt 50) {
        if (-not $p.authors -or $p.authors -eq $p.title) {
            $p.authors = $matches[1]
        }
        $t = $matches[2]
    }

    # Extract http / https URLs from title or journal into doi/link
    if ($t -match '(https?://[^\s\)]+)') {
        $url = $matches[1]
        if (-not $p.doi) {
            $p.doi = $url
        }
        $t = $t -replace 'https?://[^\s\)]+', ''
    }

    # Clean leading/trailing commas, parens, spaces
    $t = $t.Trim(' .,;:')
    $p.title = $t
}

Write-Host "Remaining N/A years count: $naCount"

# Re-save cleaned papers.json
$cleanJson = $papers | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $cleanJson, [System.Text.Encoding]::UTF8)
Write-Host "Saved cleaned papers.json successfully!"
