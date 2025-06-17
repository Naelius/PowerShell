# Variablen definieren
$name = "Martin"
$name_02 = "ein Einhorn"
$alter = 247

# Begrüßung und Vorstellung
$begrüßung = "Begrüßung:`nHallo, mein Name ist $name."
# Vorstellung
$vorstellung = "`nVorstellung:`nIch bin $name_02 und ich bin $alter Jahre alt."

# Lieblingshobby
$hobby = "In meiner Freizeit spiele ich Dungeons and Dragons und bekämpfe das Böse."

# Bonus: aktuelles Datum
$heutigesDatum = Get-Date -Format "dd.MM.yyyy"

# Ausgaben
Write-Host $begrüßung
Write-Host $vorstellung
Write-Host $hobby
Write-Host "`nHeutiges Datum: $heutigesDatum"