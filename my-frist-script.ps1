# Variablen definieren
$produktname = "Tastatur"
$stückpreis = 25.99
$anzahl = 3
$mwstSatz = 0.19    # 19% Mehrwertsteuer

# Grundpreis berechnen (ohne Mehrwertsteuer)
$grundpreis = $stückpreis * $anzahl

# Mehrwertsteuerbetrag berechnen
$mwstBetrag = $grundpreis * $mwstSatz

# Gesamtpreis (inkl. Mehrwertsteuer) berechnen
$gesamtpreis = $grundpreis + $mwstBetrag

# Ausgabe der Ergebnisse
Write-Host "Produkt: $($produktname)"
Write-Host "Stückpreis: $($stückpreis.ToString("F2")) EUR"
Write-Host "Anzahl: $($anzahl)"
Write-Host "Grundpreis (ohne MwSt.): $($grundpreis.ToString("F2")) EUR"
Write-Host "Mehrwertsteuer (${mwstSatz*100}%): $($mwstBetrag.ToString("F2")) EUR"
Write-Host "Gesamtpreis (inkl. MwSt.): $($gesamtpreis.ToString("F2")) EUR"

# Beispielzahlen
$a = 643
$b = 53

Write-Host "`n--- Rechenoperationen ---"
Write-Host "`nZahl A: $($a)"
Write-Host "Zahl B: $($b)`n"

# Addition
$summe = $a + $b
Write-Host "Addition ($a + $b): $($summe)"

# Subtraktion
$differenz = $a - $b
Write-Host "Subtraktion ($a - $b): $($differenz)"

# Multiplikation
$produkt = $a * $b
Write-Host "Multiplikation ($a * $b): $($produkt)"

# Division
# Achtung: PowerShell behandelt Divisionen standardmäßig als Gleitkommazahlen, wenn das Ergebnis keine ganze Zahl ist.
$quotient = $a / $b
Write-Host "Division ($a / $b): $($quotient.ToString("F2"))"

# Modulo (Rest bei Division)
$rest = $a % $b
Write-Host "Modulo ($a % $b - Rest bei Division): $($rest.ToString("F2"))"