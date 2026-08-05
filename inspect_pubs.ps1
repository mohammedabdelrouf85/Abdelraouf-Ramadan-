$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', [System.Text.Encoding]::UTF8)

# Let's inspect snippet of text
Write-Host "Length: $($text.Length)"
Write-Host "Sample text (first 1000 chars):"
Write-Host $text.Substring(0, [Math]::Min(1000, $text.Length))

# Let's check how many year occurrences exist like (2004), (2006), (2007), (2008)... (2025)
$yearMatches = [regex]::Matches($text, '\((19\d\d|20\d\d)\)|\b(20\d\d|19\d\d)\b')
Write-Host "Year matches count: $($yearMatches.Count)"
