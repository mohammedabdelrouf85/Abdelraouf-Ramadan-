$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', [System.Text.Encoding]::UTF8)

# Replace common Word paragraph breaks (like \r, \n, \x07, \x0b, \f) with standard newlines
$cleanText = $text -replace '[\r\n\x07\x0b\f]+', "`n"

# Split lines
$rawLines = $cleanText -split "`n"
$papers = @()

foreach ($line in $rawLines) {
    $t = $line.Trim()
    if ($t.Length -gt 15 -and ($t -match '\(\d{4}\)' -or $t -match '\b(19|20)\d\d\b')) {
        $papers += $t
    }
}

Write-Host "Count of raw lines matching papers: $($papers.Count)"

# Let's inspect first 10 papers
for ($i=0; $i -lt [Math]::Min(10, $papers.Count); $i++) {
    Write-Host "--------------------"
    Write-Host "[$($i+1)] $($papers[$i])"
}
