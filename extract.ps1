$docPath = 'C:\Users\DELL\Downloads\3- CV of Prof. Dr. Abdelraouf Ramadan, NRC, Egypt.doc'
$outputPath = 'd:\MY PC\Coding\Abdelraouf Ramadan\cv_extracted.txt'

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open($docPath)
$text = $doc.Content.Text
[System.IO.File]::WriteAllText($outputPath, $text, [System.Text.Encoding]::UTF8)
$doc.Close()
$word.Quit()
Write-Host "Success! Extracted $($text.Length) characters."
