$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', [System.Text.Encoding]::UTF8)

# Replace weird Word spaces and control characters
$clean = $text -replace '[\u00A0\uFFFD\u200B\u200C\u200D]+', ' '
$clean = $clean -replace '[\r\n\x07\x0b\f]+', "`n"

# Remove "LIST OF PUBLICATIONS" header
if ($clean.StartsWith("LIST OF PUBLICATIONS")) {
    $clean = $clean.Substring("LIST OF PUBLICATIONS".Length).Trim()
}

$rawLines = $clean -split "`n"
$mergedPapers = @()
$currentEntry = ""

foreach ($line in $rawLines) {
    $t = $line.Trim()
    if ($t.Length -eq 0) { continue }

    # Check if line looks like a NEW paper start (starts with Author name or Ramadan, A. / Suliman / Bakeer / Hozayn / etc.)
    # OR contains (YEAR) near the start of the line.
    $isNewPaper = $false
    if ($t -match '^[A-Z][a-zA-Z\.\s\-\,\;\&\u00C0-\u024F]+\(\d{4}\)' -or 
        $t -match '^[A-Z][a-zA-Z\.\s\-\,\;\&]+(19\d\d|20\d\d)\b' -or
        $t -match '^(Abdelraouf|Suliman|Bakeer|El-Saidi|Bakry|Refaie|Hozayn|Hussein|Okasha|Abul-Soud|Kassab|El-Habbasha|El-Metwally|Sami|Marzouk|Marwa|Refaie|Eid|Alashram|Hamza|Abdou|Alhashimi|Dewedar|El-Sayed|Mansour|Sabra|Ahmed|Awad|Fathy|Saad|Yasmin)' ) {
        
        # If line starts with "doi:" or "Agriculture (" or "Journal of " without author, it's a continuation of previous paper!
        if ($t -match '^(doi:|http|\bpp\b|Vol\b|Pages|DOI|Issue|Journal|Agriculture \(Pol|\d+ \(\d+\)|Egyptian Journal|Middle East J)' -and -not ($t -match '\(\d{4}\)')) {
            $isNewPaper = $false
        } else {
            $isNewPaper = $true
        }
    }

    if ($isNewPaper -and $currentEntry.Length -gt 15) {
        $mergedPapers += $currentEntry.Trim()
        $currentEntry = $t
    } else {
        if ($currentEntry.Length -gt 0) {
            $currentEntry += " " + $t
        } else {
            $currentEntry = $t
        }
    }
}

if ($currentEntry.Length -gt 15) {
    $mergedPapers += $currentEntry.Trim()
}

Write-Host "Total Merged Papers Count: $($mergedPapers.Count)"

$finalPapers = @()
$id = 1

foreach ($p in $mergedPapers) {
    # 1. Extract Year
    $year = ""
    if ($p -match '\((19\d\d|20\d\d)\)') {
        $year = $matches[1]
    } elseif ($p -match '\b(19\d\d|20\d\d)\b') {
        $year = $matches[1]
    } else {
        $year = "2020" # fallback if unspecified
    }

    # 2. Extract DOI or Link
    $doi = ""
    if ($p -match '(10\.\d{4,9}/[-._;()/:A-Za-z0-9]+)') {
        $doi = $matches[1].TrimEnd(' .;,')
    } elseif ($p -match '(https?://[^\s\)]+)') {
        $doi = $matches[1]
    }

    # 3. Separate Authors, Title, Journal
    $authors = ""
    $title = ""
    $journal = ""

    # Match Authors (Year). Title. Journal / Details
    if ($p -match '^(.*?)\((\d{4})\)\.?(.*)$') {
        $authors = $matches[1].Trim(' .;,')
        $rest = $matches[3].Trim()

        # Clean DOI/URL out of title/journal string
        $restClean = $rest -replace 'DOI:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
        $restClean = $restClean -replace 'doi:\s*10\.\d{4,9}/[-._;()/:A-Za-z0-9]+', ''
        $restClean = $restClean -replace 'https?://[^\s\)]+', ''
        $restClean = $restClean.Trim(' .,;:')

        # Split into Title vs Journal
        $parts = $restClean -split '\.\s+'
        if ($parts.Count -gt 1) {
            $title = $parts[0].Trim(' .')
            $journal = ($parts[1..($parts.Count-1)] -join '. ').Trim(' .')
        } else {
            $title = $restClean
            $journal = ""
        }
    } else {
        # Fallback split
        $title = $p -replace 'DOI:.*', '' -replace 'doi:.*', ''
        $title = $title.Trim(' .,;:')
        $authors = "Prof. Dr. Abdelraouf Ramadan et al."
    }

    if ([string]::IsNullOrWhiteSpace($authors)) {
        $authors = "Prof. Dr. Abdelraouf Ramadan et al."
    }

    $finalPapers += [PSCustomObject]@{
        id = $id
        raw = $p
        authors = $authors
        year = $year
        title = $title
        journal = $journal
        doi = $doi
    }
    $id++
}

Write-Host "Final Clean Papers Count: $($finalPapers.Count)"

$jsonOutput = $finalPapers | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $jsonOutput, [System.Text.Encoding]::UTF8)
Write-Host "Saved perfect papers.json!"
