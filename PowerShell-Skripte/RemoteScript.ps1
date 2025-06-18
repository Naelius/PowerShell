# Remote PC Neustart Skript
# Verwendung: .\RemoteRestart.ps1 -ComputerName "PC-NAME" -Credential (Get-Credential)

param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,
    
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential,
    
    [Parameter(Mandatory=$false)]
    [int]$DelaySeconds = 5,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Funktion zum Testen der Verbindung
function Test-RemoteConnection {
    param([string]$Computer)
    
    Write-Host "Teste Verbindung zu $Computer..." -ForegroundColor Yellow
    
    if (Test-Connection -ComputerName $Computer -Count 2 -Quiet) {
        Write-Host "✓ Verbindung erfolgreich" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Verbindung fehlgeschlagen" -ForegroundColor Red
        return $false
    }
}

# Hauptskript
try {
    Write-Host "=== Remote PC Neustart Skript ===" -ForegroundColor Cyan
    Write-Host "Ziel-Computer: $ComputerName" -ForegroundColor White
    
    # Verbindung testen
    if (-not (Test-RemoteConnection -Computer $ComputerName)) {
        Write-Error "Kann keine Verbindung zu $ComputerName herstellen. Skript wird beendet."
        exit 1
    }
    
    # Wenn keine Credentials übergeben wurden, nach ihnen fragen
    if (-not $Credential) {
        Write-Host "Bitte geben Sie die Anmeldedaten für den Remote-Computer ein:" -ForegroundColor Yellow
        $Credential = Get-Credential
    }
    
    # Warnung anzeigen
    Write-Host ""
    Write-Host "WARNUNG: Der Computer '$ComputerName' wird in $DelaySeconds Sekunden neugestartet!" -ForegroundColor Red
    
    if (-not $Force) {
        $confirm = Read-Host "Möchten Sie fortfahren? (j/n)"
        if ($confirm -ne "j" -and $confirm -ne "ja" -and $confirm -ne "y" -and $confirm -ne "yes") {
            Write-Host "Neustart abgebrochen." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Neustart-Befehl ausführen
    Write-Host ""
    Write-Host "Sende Neustart-Befehl an $ComputerName..." -ForegroundColor Yellow
    
    # Methode 1: Restart-Computer (empfohlen)
    try {
        Restart-Computer -ComputerName $ComputerName -Credential $Credential -Force -Wait:$false
        Write-Host "✓ Neustart-Befehl erfolgreich gesendet!" -ForegroundColor Green
    }
    catch {
        Write-Host "Methode 1 fehlgeschlagen, versuche alternative Methode..." -ForegroundColor Yellow
        
        # Methode 2: Invoke-Command mit shutdown
        try {
            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                shutdown /r /t $using:DelaySeconds /f /c "Remote-Neustart initiiert"
            }
            Write-Host "✓ Neustart-Befehl erfolgreich gesendet (Alternative Methode)!" -ForegroundColor Green
        }
        catch {
            Write-Host "Methode 2 fehlgeschlagen, versuche WMI-Methode..." -ForegroundColor Yellow
            
            # Methode 3: WMI
            try {
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -Credential $Credential
                $os.Reboot()
                Write-Host "✓ Neustart-Befehl erfolgreich gesendet (WMI-Methode)!" -ForegroundColor Green
            }
            catch {
                Write-Error "Alle Neustart-Methoden fehlgeschlagen: $_"
                exit 1
            }
        }
    }
    
    Write-Host ""
    Write-Host "Der Computer '$ComputerName' sollte jetzt neu starten." -ForegroundColor Green
    Write-Host "Überwachung der Verfügbarkeit..." -ForegroundColor Yellow
    
    # Warten bis Computer offline ist
    $offline = $false
    $timeout = 60
    $counter = 0
    
    while (-not $offline -and $counter -lt $timeout) {
        Start-Sleep -Seconds 2
        $counter += 2
        
        if (-not (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)) {
            $offline = $true
            Write-Host "✓ Computer ist offline (Neustart läuft)" -ForegroundColor Green
        } else {
            Write-Host "." -NoNewline -ForegroundColor Yellow
        }
    }
    
    if ($offline) {
        Write-Host ""
        Write-Host "Warte auf Wiederherstellung der Verbindung..." -ForegroundColor Yellow
        
        # Warten bis Computer wieder online ist
        $online = $false
        $timeout = 300  # 5 Minuten
        $counter = 0
        
        while (-not $online -and $counter -lt $timeout) {
            Start-Sleep -Seconds 5
            $counter += 5
            
            if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
                $online = $true
                Write-Host ""
                Write-Host "✓ Computer ist wieder online!" -ForegroundColor Green
            } else {
                Write-Host "." -NoNewline -ForegroundColor Yellow
            }
        }
        
        if (-not $online) {
            Write-Host ""
            Write-Host "⚠ Computer ist nach 5 Minuten noch nicht wieder erreichbar." -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "=== Neustart-Vorgang abgeschlossen ===" -ForegroundColor Cyan
}
catch {
    Write-Error "Unerwarteter Fehler: $_"
    exit 1
}