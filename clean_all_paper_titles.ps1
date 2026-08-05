$jsonText = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw
$papers = $jsonText | ConvertFrom-Json

Write-Host "Processing $($papers.Count) papers..."

foreach ($p in $papers) {
    # 1. Remove URLs from title, authors, and journal
    $p.title = $p.title -replace 'https?://[^\s\,\)]+', ''
    $p.title = $p.title -replace 'www\.[^\s\,\)]+', ''
    $p.journal = $p.journal -replace 'https?://[^\s\,\)]+', ''
    $p.journal = $p.journal -replace 'www\.[^\s\,\)]+', ''
    
    # Also remove URLs from DOI field as requested ("remove the link")
    $p.doi = ""

    # 2. Clean Book Chapter prefixes
    # e.g., "Book Chapter 4 (Engineering Techniques for Increasing Water Use Efficiency under Arid Zones Conditions) in book (SOIL CHARACTERISTICS AND AGRO-ECOLOGY)), New Delhi, India"
    if ($p.title -match 'Book Chapter \d+ \((.*?)\) in book \((.*?)\)(.*)') {
        $chapterTitle = $matches[1].Trim()
        $bookName = $matches[2].Trim()
        $extra = $matches[3].Trim(' .,;:')
        $p.title = $chapterTitle
        $p.journal = "Book: $bookName $extra".Trim()
    } elseif ($p.title -match 'Book Chapter \d+ \((.*?)\)(.*)') {
        $p.title = $matches[1].Trim()
        $p.journal = $matches[2].Trim(' .,;:')
    }

    # If title starts with "Abdelraouf, R. E., " or similar author string, remove it
    if ($p.title -match '^(Abdelraouf,\s*R\.\s*E\.\s*\,?\s*|Abdelraouf\s+Ramadan\s*\,?\s*)(.*)$') {
        $p.title = $matches[2].Trim()
    }

    # 3. Fix Paper #8 Year if needed
    if ($p.id -eq 8 -and $p.year -eq "2020") {
        $p.year = "2012"
    }

    # 4. Clean trailing commas, extra spaces, empty parens
    $p.title = $p.title -replace '\s+', ' '
    $p.title = $p.title.Trim(' .,;:')
    
    $p.journal = $p.journal -replace '\s+', ' '
    $p.journal = $p.journal.Trim(' .,;:')

    $p.authors = $p.authors -replace '\s+', ' '
    $p.authors = $p.authors.Trim(' .,;:')
}

$cleanJson = $papers | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $cleanJson, [System.Text.Encoding]::UTF8)
Write-Host "Cleaned all titles, removed links, and updated papers.json!"
