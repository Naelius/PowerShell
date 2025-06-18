# Windows 11 Remote-Verwaltung Setup - Direkte Ausführung
# Dieses Skript kann direkt in PowerShell eingegeben werden

# Farben für Output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

# Funktion zum Prüfen der Admin-Rechte
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Funktion für formatierten Output
function Write-Status {
    param([string]$Message, [string]$Color = "White", [string]$Status = "INFO")
    Write-Host "[$Status] $Message" -ForegroundColor $Color
}

Write-Host "================================================================" -ForegroundColor $Cyan
Write-Host "    Windows 11 Remote-Verwaltung Setup" -ForegroundColor $Cyan
Write-Host "================================================================" -ForegroundColor $Cyan
Write-Host ""

# Admin-Rechte prüfen
if (-not (Test-Administrator)) {
    Write-Status "FEHLER: Dieses Skript muss als Administrator ausgeführt werden!" -Color $Red -Status "ERROR"
    Write-Status "Starten Sie PowerShell als Administrator neu!" -Color $Yellow
    return
}

Write-Status "Administrator-Rechte bestätigt" -Color $Green -Status "OK"
Write-Host ""

# 1. PowerShell Remoting aktivieren
Write-Status "=== PowerShell Remoting konfigurieren ===" -Color $Cyan

try {
    Write-Status "Aktiviere PowerShell Remoting..." -Color $Yellow
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    
    Write-Status "Konfiguriere WinRM..." -Color $Yellow
    winrm quickconfig -q
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    
    Write-Status "Konfiguriere TrustedHosts..." -Color $Yellow
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    
    Write-Status "✓ PowerShell Remoting aktiviert" -Color $Green -Status "OK"
}
catch {
    Write-Status "✗ Fehler bei PowerShell Remoting: $_" -Color $Red -Status "ERROR"
}
Write-Host ""

# 2. Remote Desktop aktivieren
Write-Status "=== Remote Desktop konfigurieren ===" -Color $Cyan

try {
    Write-Status "Aktiviere Remote Desktop..." -Color $Yellow
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0
    
    Write-Status "✓ Remote Desktop aktiviert" -Color $Green -Status "OK"
}
catch {
    Write-Status "✗ Fehler bei Remote Desktop: $_" -Color $Red -Status "ERROR"
}
Write-Host ""

# 3. Windows-Dienste konfigurieren
Write-Status "=== Windows-Dienste konfigurieren ===" -Color $Cyan

$services = @("WinRM", "TermService", "RemoteRegistry")

foreach ($serviceName in $services) {
    try {
        $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($svc) {
            Write-Status "Konfiguriere Dienst: $serviceName" -Color $Yellow
            Set-Service -Name $serviceName -StartupType Automatic
            Start-Service -Name $serviceName -ErrorAction SilentlyContinue
            Write-Status "✓ Dienst $serviceName konfiguriert" -Color $Green -Status "OK"
        }
    }
    catch {
        Write-Status "⚠ Warnung bei Dienst $serviceName : $_" -Color $Yellow -Status "WARN"
    }
}
Write-Host ""

# 4. Firewall-Regeln aktivieren
Write-Status "=== Firewall-Regeln aktivieren ===" -Color $Cyan

try {
    Write-Status "Aktiviere Windows Remote Management Regeln..." -Color $Yellow
    netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
    
    Write-Status "Aktiviere Remote Desktop Regeln..." -Color $Yellow
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
    
    Write-Status "Aktiviere WMI Regeln..." -Color $Yellow
    netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=yes
    
    Write-Status "✓ Firewall-Regeln aktiviert" -Color $Green -Status "OK"
}
catch {
    Write-Status "⚠ Warnung bei Firewall-Regeln: $_" -Color $Yellow -Status "WARN"
}
Write-Host ""

# 5. Netzwerk-Profil auf Private setzen
Write-Status "=== Netzwerk-Profil konfigurieren ===" -Color $Cyan

try {
    $networkProfiles = Get-NetConnectionProfile
    foreach ($profile in $networkProfiles) {
        if ($profile.NetworkCategory -eq "Public") {
            Write-Status "Ändere Netzwerk-Profil zu Private: $($profile.Name)" -Color $Yellow
            Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private
            Write-Status "✓ Netzwerk-Profil geändert" -Color $Green -Status "OK"
        }
    }
}
catch {
    Write-Status "⚠ Warnung bei Netzwerk-Profil: $_" -Color $Yellow -Status "WARN"
}
Write-Host ""

# 6. Registry-Einstellungen
Write-Status "=== Registry-Optimierungen ===" -Color $Cyan

try {
    Write-Status "Konfiguriere UAC für Remote-Verbindungen..." -Color $Yellow
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -PropertyType DWORD -Force | Out-Null
    
    Write-Status "✓ Registry-Optimierungen abgeschlossen" -Color $Green -Status "OK"
}
catch {
    Write-Status "⚠ Warnung bei Registry-Einstellungen: $_" -Color $Yellow -Status "WARN"
}
Write-Host ""

# 7. Konfiguration testen
Write-Status "=== Konfiguration testen ===" -Color $Cyan

try {
    $winrmTest = Test-WSMan -ComputerName localhost -ErrorAction SilentlyContinue
    if ($winrmTest) {
        Write-Status "✓ WinRM funktioniert" -Color $Green -Status "OK"
    } else {
        Write-Status "⚠ WinRM-Test fehlgeschlagen" -Color $Yellow -Status "WARN"
    }
    
    $rdpTest = Test-NetConnection -ComputerName localhost -Port 3389 -InformationLevel Quiet
    if ($rdpTest) {
        Write-Status "✓ RDP Port 3389 ist erreichbar" -Color $Green -Status "OK"
    } else {
        Write-Status "⚠ RDP Port 3389 nicht erreichbar" -Color $Yellow -Status "WARN"
    }
    
    $networkInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}
    Write-Status "IP-Adressen dieser Maschine:" -Color $Green
    foreach ($ip in $networkInfo) {
        Write-Status "  - $($ip.IPAddress)" -Color $Green
    }
}
catch {
    Write-Status "⚠ Warnung beim Testen: $_" -Color $Yellow -Status "WARN"
}
Write-Host ""

# Zusammenfassung
Write-Host "================================================================" -ForegroundColor $Cyan
Write-Host "    SETUP ABGESCHLOSSEN" -ForegroundColor $Cyan
Write-Host "================================================================" -ForegroundColor $Cyan
Write-Host ""

Write-Status "AKTIVIERTE DIENSTE:" -Color $Cyan
Write-Status "✓ PowerShell Remoting (Port 5985/5986)" -Color $Green
Write-Status "✓ Remote Desktop (Port 3389)" -Color $Green
Write-Status "✓ WMI für Remote-Verwaltung" -Color $Green
Write-Status "✓ Firewall-Regeln konfiguriert" -Color $Green

Write-Host ""
Write-Status "TESTEN SIE DIE KONFIGURATION:" -Color $Cyan
Write-Host "Von einem anderen PC aus:" -ForegroundColor $Yellow
Write-Host "  Test-WSMan -ComputerName <DIESE-IP>" -ForegroundColor $Yellow
Write-Host "  Enter-PSSession -ComputerName <DIESE-IP>" -ForegroundColor $Yellow
Write-Host "  mstsc /v:<DIESE-IP>" -ForegroundColor $Yellow
Write-Host ""

Write-Status "Ein Neustart wird empfohlen!" -Color $Yellow
Write-Host "Führen Sie 'Restart-Computer' aus wenn Sie bereit sind." -ForegroundColor $Yellow