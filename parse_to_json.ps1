$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', [System.Text.Encoding]::UTF8)

# Replace weird Word characters
$cleanText = $text -replace '[\u00A0\uFFFD\u200B\u200C\u200D]+', ' '
$cleanText = $cleanText -replace '[\r\n\x07\x0b\f]+', "`n"

$rawLines = $cleanText -split "`n"
$papersList = @()

foreach ($line in $rawLines) {
    $t = $line.Trim()
    # Exclude header line if any
    if ($t.StartsWith("LIST OF PUBLICATIONS")) {
        $t = $t.Substring("LIST OF PUBLICATIONS".Length).Trim()
    }
    if ($t.Length -gt 15) {
        $papersList += $t
    }
}

Write-Host "Total Clean Lines: $($papersList.Count)"

$structuredPapers = @()
$id = 1

foreach ($p in $papersList) {
    # Extract Year
    $year = "N/A"
    if ($p -match '\((19\d\d|20\d\d)\)') {
        $year = $matches[1]
    } elseif ($p -match '\b(19\d\d|20\d\d)\b') {
        $year = $matches[1]
    }

    # Clean title / author extraction heuristic
    # Usually: Authors (Year). Title. Journal / Details...
    $authors = ""
    $title = ""
    $journal = ""
    $doi = ""

    if ($p -match '^(.*?)\((\d{4})\)\.?(.*)$') {
        $authors = $matches[1].Trim(' .;,')
        $year = $matches[2]
        $rest = $matches[3].Trim()
        
        # Split rest into title and journal if possible
        $parts = $rest -split '\.\s+'
        if ($parts.Count -gt 1) {
            $title = $parts[0].Trim(' .')
            $journal = ($parts[1..($parts.Count-1)] -join '. ').Trim(' .')
        } else {
            $title = $rest
            $journal = ""
        }
    } else {
        $title = $p
    }

    # Extract DOI if present
    if ($p -match '(10\.\d{4,9}/[-._;()/:A-Za-z0-9]+)') {
        $doi = $matches[1].TrimEnd(' .;,')
    }

    $structuredPapers += [PSCustomObject]@{
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

Write-Host "Structured Papers Count: $($structuredPapers.Count)"

$jsonContent = $structuredPapers | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $jsonContent, [System.Text.Encoding]::UTF8)
Write-Host "Saved papers.json successfully!"
