# Software Installer Menü - Windows 11
# Automatischer Download und Installation von Software

# Farben für Output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$White = "White"

# Software-Definitionen
$SoftwareList = @{
    "1" = @{
        Name = "Mozilla Firefox"
        Url = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=de"
        Type = "exe"
        InstallArgs = "/S"
        Description = "Webbrowser"
    }
    "2" = @{
        Name = "Google Chrome"
        Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        Type = "exe"
        InstallArgs = "/silent /install"
        Description = "Webbrowser"
    }
    "3" = @{
        Name = "BGInfo"
        Url = "https://download.sysinternals.com/files/BGInfo.zip"
        Type = "zip"
        InstallArgs = ""
        Description = "System Information Display"
    }
    "4" = @{
        Name = "7-Zip"
        Url = "https://www.7-zip.org/a/7z2301-x64.exe"
        Type = "exe"
        InstallArgs = "/S"
        Description = "Archiv-Manager"
    }
    "5" = @{
        Name = "Notepad++"
        Url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.8/npp.8.5.8.Installer.x64.exe"
        Type = "exe"
        InstallArgs = "/S"
        Description = "Text-Editor"
    }
    "6" = @{
        Name = "VLC Media Player"
        Url = "https://get.videolan.org/vlc/3.0.18/win64/vlc-3.0.18-win64.exe"
        Type = "exe"
        InstallArgs = "/L=1031 /S"
        Description = "Media Player"
    }
    "7" = @{
        Name = "Adobe Acrobat Reader DC"
        Url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300820360/AcroRdrDC2300820360_de_DE.exe"
        Type = "exe"
        InstallArgs = "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
        Description = "PDF Reader"
    }
    "8" = @{
        Name = "Microsoft Visual Studio Code"
        Url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
        Type = "exe"
        InstallArgs = "/VERYSILENT /NORESTART /MERGETASKS=!runcode"
        Description = "Code Editor"
    }
    "9" = @{
        Name = "WinRAR"
        Url = "https://www.rarlab.com/rar/winrar-x64-623d.exe"
        Type = "exe"
        InstallArgs = "/S"
        Description = "Archiv-Manager"
    }
    "10" = @{
        Name = "TeamViewer"
        Url = "https://download.teamviewer.com/download/TeamViewer_Setup.exe"
        Type = "exe"
        InstallArgs = "/S"
        Description = "Remote Desktop"
    }
    "11" = @{
        Name = "Paint.NET"
        Url = "https://github.com/paintdotnet/release/releases/download/v5.0.9/paint.net.5.0.9.install.anycpu.web.exe"
        Type = "exe"
        InstallArgs = "/auto DESKTOPSHORTCUT=0"
        Description = "Bildbearbeitung"
    }
    "12" = @{
        Name = "Putty"
        Url = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.78-installer.msi"
        Type = "msi"
        InstallArgs = "/quiet /norestart"
        Description = "SSH Client"
    }
}

# Globale Variablen
$DownloadPath = "$env:TEMP\SoftwareInstaller"
$LogFile = "$DownloadPath\install.log"

# Funktionen
function Write-Status {
    param([string]$Message, [string]$Color = "White", [string]$Status = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] [$Status] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Initialize-Environment {
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
    }
    
    Write-Status "Download-Verzeichnis: $DownloadPath" -Color $Cyan
    Write-Status "Log-Datei: $LogFile" -Color $Cyan
}

function Show-Menu {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor $Cyan
    Write-Host "           SOFTWARE INSTALLER MENÜ" -ForegroundColor $Cyan
    Write-Host "================================================================" -ForegroundColor $Cyan
    Write-Host ""
    
    Write-Host "Verfügbare Software:" -ForegroundColor $Yellow
    Write-Host ""
    
    foreach ($key in ($SoftwareList.Keys | Sort-Object {[int]$_})) {
        $software = $SoftwareList[$key]
        $status = if (Test-SoftwareInstalled -Name $software.Name) { 
            "[INSTALLIERT]" 
        } else { 
            "[NICHT INSTALLIERT]" 
        }
        
        $statusColor = if ($status -eq "[INSTALLIERT]") { $Green } else { $Red }
        
        Write-Host ("{0,2}. {1,-30} - {2}" -f $key, $software.Name, $software.Description) -ForegroundColor $White
        Write-Host ("    {0}" -f $status) -ForegroundColor $statusColor
        Write-Host ""
    }
    
    Write-Host "================================================================" -ForegroundColor $Cyan
    Write-Host "Optionen:" -ForegroundColor $Yellow
    Write-Host "Geben Sie eine oder mehrere Zahlen (z.B. 1,3,5) ein, um einzelne Programme auszuwählen." -ForegroundColor $White
    Write-Host "Oder wählen Sie einen der folgenden Buchstaben für eine Aktion:" -ForegroundColor $White
    Write-Host "A. Alle Software installieren" -ForegroundColor $White
    Write-Host "U. Nur nicht installierte Software installieren" -ForegroundColor $White
    Write-Host "L. Log-Datei anzeigen" -ForegroundColor $White
    Write-Host "C. Download-Cache löschen" -ForegroundColor $White
    Write-Host "Q. Beenden" -ForegroundColor $White
    Write-Host ""
}

function Test-SoftwareInstalled {
    param([string]$Name)
    
    # Vereinfachte Prüfung - checkt häufige Installation-Pfade
    $commonPaths = @(
        "${env:ProgramFiles}\*$Name*",
        "${env:ProgramFiles(x86)}\*$Name*",
        "$env:LOCALAPPDATA\*$Name*"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Registry-Prüfung für installierte Programme
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($regPath in $registryPaths) {
        $installedSoftware = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | 
                           Where-Object { $_.DisplayName -like "*$Name*" }
        if ($installedSoftware) {
            return $true
        }
    }
    
    return $false
}

function Download-Software {
    param([hashtable]$Software, [string]$Key)
    
    $fileName = "$Key-" + ($Software.Url -split '/')[-1]
    if ($fileName -notmatch '\.(exe|msi|zip)$') {
        $fileName += ".$($Software.Type)"
    }
    
    $filePath = Join-Path $DownloadPath $fileName
    
    if (Test-Path $filePath) {
        Write-Status "Datei bereits vorhanden: $fileName" -Color $Yellow
        return $filePath
    }
    
    Write-Status "Lade herunter: $($Software.Name)" -Color $Yellow
    Write-Status "URL: $($Software.Url)" -Color $Cyan
    
    try {
        # Verwende Invoke-WebRequest mit besserer Kompatibilität
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Software.Url -OutFile $filePath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        if (Test-Path $filePath) {
            $fileSize = [math]::Round((Get-Item $filePath).Length / 1MB, 2)
            Write-Status "✓ Download erfolgreich: $fileName ($fileSize MB)" -Color $Green
            return $filePath
        } else {
            throw "Datei wurde nicht erstellt"
        }
    }
    catch {
        Write-Status "✗ Download fehlgeschlagen: $($_.Exception.Message)" -Color $Red
        return $null
    }
}

function Install-Software {
    param([hashtable]$Software, [string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Status "✗ Datei nicht gefunden: $FilePath" -Color $Red
        return $false
    }
    
    Write-Status "Installiere: $($Software.Name)" -Color $Yellow
    
    try {
        switch ($Software.Type.ToLower()) {
            "exe" {
                $process = Start-Process -FilePath $FilePath -ArgumentList $Software.InstallArgs -Wait -PassThru
                if ($process.ExitCode -eq 0) {
                    Write-Status "✓ Installation erfolgreich: $($Software.Name)" -Color $Green
                    return $true
                } else {
                    Write-Status "⚠ Installation mit Exit-Code $($process.ExitCode): $($Software.Name)" -Color $Yellow
                    return $true  # Manche Programme haben andere Success-Codes
                }
            }
            "msi" {
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$FilePath`" $($Software.InstallArgs)" -Wait -PassThru
                if ($process.ExitCode -eq 0) {
                    Write-Status "✓ Installation erfolgreich: $($Software.Name)" -Color $Green
                    return $true
                } else {
                    Write-Status "⚠ Installation mit Exit-Code $($process.ExitCode): $($Software.Name)" -Color $Yellow
                    return $true
                }
            }
            "zip" {
                $extractPath = Join-Path $DownloadPath ($Software.Name -replace '[^\w]', '')
                
                if (-not (Test-Path $extractPath)) {
                    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
                }
                
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($FilePath, $extractPath)
                
                Write-Status "✓ Archiv entpackt nach: $extractPath" -Color $Green
                
                # Für BGInfo: Kopiere nach Programme-Ordner und erstelle Desktop-Verknüpfung
                if ($Software.Name -like "*BGInfo*") {
                    $bgInfoPath = "${env:ProgramFiles}\BGInfo"
                    if (-not (Test-Path $bgInfoPath)) {
                        New-Item -ItemType Directory -Path $bgInfoPath -Force | Out-Null
                    }
                    
                    $bgInfoExe = Get-ChildItem -Path $extractPath -Name "*.exe" | Select-Object -First 1
                    if ($bgInfoExe) {
                        Copy-Item -Path (Join-Path $extractPath $bgInfoExe) -Destination $bgInfoPath -Force
                        
                        # Desktop-Verknüpfung erstellen
                        $WshShell = New-Object -comObject WScript.Shell
                        $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\BGInfo.lnk")
                        $Shortcut.TargetPath = Join-Path $bgInfoPath $bgInfoExe
                        $Shortcut.Arguments = "/accepteula /timer:0"
                        $Shortcut.Save()
                        
                        Write-Status "✓ BGInfo Desktop-Verknüpfung erstellt" -Color $Green
                    }
                }
                
                return $true
            }
            default {
                Write-Status "✗ Unbekannter Dateityp: $($Software.Type)" -Color $Red
                return $false
            }
        }
    }
    catch {
        Write-Status "✗ Installation fehlgeschlagen: $($_.Exception.Message)" -Color $Red
        return $false
    }
}

function Install-SelectedSoftware {
    param([string[]]$Keys)
    
    $successCount = 0
    $totalCount = $Keys.Count
    
    Write-Status "Starte Installation von $totalCount Programm(en)" -Color $Cyan
    
    foreach ($key in $Keys) {
        $software = $SoftwareList[$key]
        Write-Host ""
        Write-Status "=== $($software.Name) ===" -Color $Cyan
        
        # Download
        $filePath = Download-Software -Software $software -Key $key
        if (-not $filePath) {
            continue
        }
        
        # Installation
        if (Install-Software -Software $software -FilePath $filePath) {
            $successCount++
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
    Write-Status "Installation abgeschlossen: $successCount/$totalCount erfolgreich" -Color $Green
    Write-Host ""
    Read-Host "Drücken Sie Enter um fortzufahren"
}

function Show-Log {
    if (Test-Path $LogFile) {
        Write-Host ""
        Write-Host "=== LOG-DATEI ===" -ForegroundColor $Cyan
        Get-Content $LogFile | Select-Object -Last 50
    } else {
        Write-Status "Keine Log-Datei gefunden" -Color $Yellow
    }
    Write-Host ""
    Read-Host "Drücken Sie Enter um fortzufahren"
}

function Clear-Cache {
    if (Test-Path $DownloadPath) {
        try {
            Remove-Item -Path "$DownloadPath\*" -Recurse -Force
            Write-Status "✓ Download-Cache geleert" -Color $Green
        }
        catch {
            Write-Status "⚠ Fehler beim Leeren des Caches: $_" -Color $Yellow
        }
    }
    Read-Host "Drücken Sie Enter um fortzufahren"
}

# Hauptprogramm
function Main {
    # Administrator-Rechte prüfen
    if (-not (Test-Administrator)) {
        Write-Host "WARNUNG: Dieses Skript sollte als Administrator ausgeführt werden!" -ForegroundColor $Red
        Write-Host "Einige Installationen könnten fehlschlagen." -ForegroundColor $Yellow
        Write-Host ""
        $continue = Read-Host "Trotzdem fortfahren? (j/n)"
        if ($continue -ne "j" -and $continue -ne "ja") {
            exit
        }
    }
    
    Initialize-Environment
    
    while ($true) {
        Show-Menu

        $choice = Read-Host "Ihre Wahl (z.B. 1,3,5 für mehrere Programme oder Buchstabe für Aktion)"

        switch ($choice.ToUpper()) {
            "Q" { 
                Write-Status "Programm beendet" -Color $Cyan
                exit 
            }
            "A" {
                $confirm = Read-Host "Wirklich ALLE Programme installieren? (j/n)"
                if ($confirm -eq "j" -or $confirm -eq "ja") {
                    $allKeys = $SoftwareList.Keys | Sort-Object {[int]$_}
                    Install-SelectedSoftware -Keys $allKeys
                }
            }
            "U" {
                $confirm = Read-Host "Wirklich alle NICHT installierten Programme installieren? (j/n)"
                if ($confirm -eq "j" -or $confirm -eq "ja") {
                    $uninstalledKeys = @()
                    foreach ($key in ($SoftwareList.Keys | Sort-Object {[int]$_})) {
                        if (-not (Test-SoftwareInstalled -Name $SoftwareList[$key].Name)) {
                            $uninstalledKeys += $key
                        }
                    }
                    if ($uninstalledKeys.Count -gt 0) {
                        Install-SelectedSoftware -Keys $uninstalledKeys
                    } else {
                        Write-Status "Alle Programme sind bereits installiert!" -Color $Green
                        Read-Host "Drücken Sie Enter um fortzufahren"
                    }
                }
            }
            "L" {
                Show-Log
            }
            "C" {
                $confirm = Read-Host "Download-Cache wirklich löschen? (j/n)"
                if ($confirm -eq "j" -or $confirm -eq "ja") {
                    Clear-Cache
                }
            }
            default {
                # NEU: Mehrfachauswahl per Komma
                $selectedKeys = $choice -split "," | ForEach-Object { $_.Trim() } | Where-Object { $SoftwareList.ContainsKey($_) }
                if ($selectedKeys.Count -gt 0) {
                    $confirm = Read-Host "Wirklich folgende Programme installieren: $($selectedKeys -join ', ')? (j/n)"
                    if ($confirm -eq "j" -or $confirm -eq "ja") {
                        Install-SelectedSoftware -Keys $selectedKeys
                    }
                } else {
                    Write-Host "Ungültige Auswahl!" -ForegroundColor $Red
                    Start-Sleep -Seconds 1
                }
            }
        }
    }
}

# Skript starten
Main