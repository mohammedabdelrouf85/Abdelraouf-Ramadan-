$jsonText = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw
$papers = $jsonText | ConvertFrom-Json

Write-Host "Initial Papers Count: $($papers.Count)"

$cleanedList = @()

for ($i = 0; $i -lt $papers.Count; $i++) {
    $p = $papers[$i]

    # Check if this paper is actually a fragment (e.g. title starts with "doi:" or "http" or is shorter than 15 chars)
    if ($p.title -match '^(doi:|DOI:|https?://)' -or $p.title.Length -lt 15) {
        Write-Host "Found fragment at index $i (id $($p.id)): '$($p.title)'"
        # Merge info into preceding paper if exists
        if ($cleanedList.Count -gt 0) {
            $prev = $cleanedList[$cleanedList.Count - 1]
            if ($p.title -match '(10\.\d{4,9}/[-._;()/:A-Za-z0-9]+)') {
                $prev.journal += " (DOI: " + $matches[1] + ")"
            }
        }
        continue # Skip adding fragment as a separate card!
    }

    # Ensure Year is valid (no N/A)
    if ($p.year -eq "N/A" -or [string]::IsNullOrWhiteSpace($p.year)) {
        if ($p.raw -match '\b(19\d\d|20\d\d)\b') {
            $p.year = $matches[1]
        } else {
            $p.year = "2019" # default fallback
        }
    }

    # Clean title text: strip any "doi: ..." or "DOI: ..." or URLs embedded in title
    $p.title = $p.title -replace 'DOI:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
    $p.title = $p.title -replace 'doi:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
    $p.title = $p.title -replace 'doi:.*', ''
    $p.title = $p.title -replace 'DOI:.*', ''
    $p.title = $p.title -replace 'https?://[^\s\)]+', ''
    $p.title = $p.title -replace 'www\.[^\s\)]+', ''
    $p.title = $p.title.Trim(' .,;:')

    # Clean journal text
    $p.journal = $p.journal -replace 'DOI:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
    $p.journal = $p.journal -replace 'doi:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
    $p.journal = $p.journal -replace 'https?://[^\s\)]+', ''
    $p.journal = $p.journal.Trim(' .,;:')

    # Remove doi link field completely
    $p.doi = ""

    $cleanedList += $p
}

# Re-index IDs cleanly 1..N
$id = 1
foreach ($c in $cleanedList) {
    $c.id = $id
    $id++
}

Write-Host "Final Cleaned Papers Count: $($cleanedList.Count)"

$finalJson = $cleanedList | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $finalJson, [System.Text.Encoding]::UTF8)
Write-Host "Successfully saved pristine papers.json without fragments!"
