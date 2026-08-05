$text = [System.IO.File]::ReadAllText('d:\MY PC\Coding\Abdelraouf Ramadan\cv_extracted.txt', [System.Text.Encoding]::UTF8)

# Output basic information
Write-Host "Full Length: $($text.Length)"

# Save all sections into readable files or stdout
$pubStart = $text.IndexOf("LIST OF PUBLICATIONS")
$revStart = $text.IndexOf("REVIEWER IN INTERNATIONAL JOURNALS")
$projStart = $text.IndexOf("RESEARCH PROJECTS")
$trainStart = $text.IndexOf("TRAINING AND WORKSHOPS")

Write-Host "Publication start: $pubStart, Reviewer start: $revStart, Projects start: $projStart, Training start: $trainStart"

if ($pubStart -ge 0) {
    $pubsOnly = $text.Substring($pubStart)
    if ($revStart -gt $pubStart) {
        $pubsOnly = $text.Substring($pubStart, $revStart - $pubStart)
    }
    [System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\publications_all.txt', $pubsOnly, [System.Text.Encoding]::UTF8)
}
