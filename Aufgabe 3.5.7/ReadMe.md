# VM einrichten – PowerShell-Skript

## Übersicht

Dieses PowerShell-Skript automatisiert die grundlegende Einrichtung einer Windows-VM. Es richtet Remotedesktop ein, benennt den PC um, aktiviert das Administrator-Konto, setzt ein neues Passwort, konfiguriert die Netzwerkeinstellungen, ändert die Hintergrundfarbe, lädt BGInfo herunter und startet den PC neu.

---

## Funktionen im Überblick

1. **Remotedesktop aktivieren**  
   - Aktiviert Remotedesktop-Verbindungen.
   - Öffnet die Windows-Firewall für Remotedesktop.

2. **PC umbenennen**  
   - Setzt den Computernamen auf den Wert der Variable `$neuerName`.

3. **Administrator aktivieren**  
   - Aktiviert das integrierte Administrator-Konto.

4. **Administrator-Passwort setzen**  
   - Setzt das Passwort für das Administrator-Konto auf den Wert der Variable `$adminPass`.

5. **IP-Adresse und DNS konfigurieren**  
   - Setzt eine statische IP-Adresse, Gateway und DNS-Server für den ersten aktiven Netzwerkadapter.

6. **Hintergrundfarbe ändern**  
   - Setzt die Desktop-Hintergrundfarbe auf grün.
   - Entfernt das Hintergrundbild.

7. **BGInfo herunterladen und starten**  
   - Lädt BGInfo von Microsoft herunter, entpackt es und startet das Tool.

8. **Neustart**  
   - Informiert den Benutzer und startet den PC nach 10 Sekunden neu.

---

## Nutzung

1. **Variablen anpassen:**  
   - Passe `$neuerName`, `$adminPass`, die IP-Adresse, das Gateway und die DNS-Server nach Bedarf an.

2. **Skript als Administrator ausführen:**  
   - Rechtsklick auf PowerShell → „Als Administrator ausführen“  
   - Skript starten:
     ```powershell
     .\VM einrichten.ps1
     ```

3. **Hinweise:**  
   - Das Skript startet den PC automatisch neu.
   - BGInfo wird nach dem Download gestartet, aber nicht automatisch konfiguriert.
   - Die Hintergrundfarbe ist nur sichtbar, wenn kein Hintergrundbild gesetzt ist.

---

## Sicherheitshinweise

- Setze ein sicheres Passwort für das Administrator-Konto!
- Prüfe die Netzwerkeinstellungen, um IP-Konflikte zu vermeiden.
- Das Skript ist für Test- und Lernzwecke gedacht. Für produktive Umgebungen ggf. anpassen.

---

## Lizenz

Dieses Skript darf frei verwendet und angepasst werden.