$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', [System.Text.Encoding]::UTF8)

# Split by paper entry patterns.
# Papers in CV are formatted like:
# Author(s) (Year). Title. Journal / Conference, Volume, pages, DOI/URL.

$lines = $text -split "`r`n"
$papers = @()
$currentPaper = ""

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0) { continue }
    
    # Check if this line looks like the start of a new paper (e.g., contains a year in parens like (2004) or Author names)
    if ($trimmed -match '^([A-Z][a-zA-Z\.\s\-\,\;]+)(\(\d{4}\))' -or $trimmed -match '^([A-Z][a-zA-Z\.\s\-\,\;]+)\s+(\d{4})\b') {
        if ($currentPaper.Length -gt 10) {
            $papers += $currentPaper.Trim()
        }
        $currentPaper = $trimmed
    } else {
        if ($currentPaper.Length -gt 0) {
            $currentPaper += " " + $trimmed
        } else {
            $currentPaper = $trimmed
        }
    }
}
if ($currentPaper.Length -gt 10) {
    $papers += $currentPaper.Trim()
}

Write-Host "Total Parsed Papers: $($papers.Count)"

# Export papers as JSON
$paperObjects = @()
$id = 1
foreach ($p in $papers) {
    # Extract Year
    $year = "N/A"
    if ($p -match '\((\d{4})\)' -or $p -match '\b(19\d\d|20\d\d)\b') {
        $year = $matches[1]
    }
    
    $paperObjects += [PSCustomObject]@{
        id = $id
        raw = $p
        year = $year
    }
    $id++
}

$paperObjects | ConvertTo-Json -Depth 3 | Out-File -FilePath 'd:\MY PC\Coding\Abdelraouf Ramadan\parsed_papers.json' -Encoding utf8
Write-Host "Saved parsed_papers.json"
