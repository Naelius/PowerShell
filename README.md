# PowerShell-Skript: Produktpreisberechnung & Rechenoperationen

## Übersicht

Dieses PowerShell-Skript berechnet den Gesamtpreis eines Produkts inklusive Mehrwertsteuer und demonstriert grundlegende mathematische Operationen (Addition, Subtraktion, Multiplikation, Division, Modulo) mit Beispielzahlen. Es eignet sich als Lernbeispiel für Variablen, mathematische Berechnungen und die Formatierung von Ausgaben in PowerShell.

---

## Funktionsweise

### 1. Produktpreisberechnung

Das Skript berechnet anhand vordefinierter Variablen:
- **Produktname**
- **Stückpreis**
- **Anzahl**
- **Mehrwertsteuersatz**

die folgenden Werte:
- **Grundpreis** (ohne MwSt.)
- **Mehrwertsteuerbetrag**
- **Gesamtpreis** (inkl. MwSt.)

Alle Preise werden mit zwei Nachkommastellen ausgegeben.

**Beispielausgabe:**
```
Produkt: Tastatur
Stückpreis: 25.99 EUR
Anzahl: 3
Grundpreis (ohne MwSt.): 77.97 EUR
Mehrwertsteuer (19%): 14.81 EUR
Gesamtpreis (inkl. MwSt.): 92.78 EUR
```

---

### 2. Mathematische Rechenoperationen

Mit den Beispielzahlen `$a = 643` und `$b = 53` werden folgende Operationen durchgeführt und ausgegeben:
- Addition
- Subtraktion
- Multiplikation
- Division (mit 2 Nachkommastellen)
- Modulo (Rest bei Division, mit 2 Nachkommastellen)

**Beispielausgabe:**
```
--- Rechenoperationen ---

Zahl A: 643
Zahl B: 53

Addition (643 + 53): 696
Subtraktion (643 - 53): 590
Multiplikation (643 * 53): 34079
Division (643 / 53): 12.13
Modulo (643 % 53 - Rest bei Division): 9.00
```

---

## Hinweise zur Ausführung

1. **Speichern:**  
   Speichere das Skript als `my-frist-script.ps1`.

2. **Ausführen:**  
   Öffne PowerShell als Administrator und führe das Skript aus:
   ```powershell
   cd "C:\Users\Administrator\Documents\PowerShell"
   .\my-frist-script.ps1
   ```

3. **Ausführungsrichtlinie:**  
   Falls nötig, setze die Ausführungsrichtlinie:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```

---

## Anpassungen

- **Produktdaten:**  
  Passe die Variablen `$produktname`, `$stückpreis`, `$anzahl` und `$mwstSatz` nach Bedarf an.
- **Rechenoperationen:**  
  Ändere die Werte von `$a` und `$b`, um andere Beispiele zu testen.

---

## Lerninhalte

- Arbeiten mit Variablen in PowerShell
- Mathematische Berechnungen
- Formatierte Ausgabe mit `.ToString("F2")` für zwei Nachkommastellen
- Zeilenumbrüche mit `` `n ``
- Grundlegende PowerShell-Syntax

---

## Lizenz

Dieses Skript dient zu Lernzwecken und kann frei verwendet und angepasst werden.
