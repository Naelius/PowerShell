# VM Einrichtungsskript

# --- Remotedesktop aktivieren ---
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remotedesktop"

# --- PC umbenennen ---
$neuerName = "MeinVMName" # Bitte ändere den Namen
Rename-Computer -NewName $neuerName -Force

# --- Administrator aktivieren ---
net user Administrator /active:yes

# --- Passwort für Administrator setzen ---
$adminPass = "DeinSicheresPasswort123!" # Bitte ändere das Passwort zu einem sicheren Wert
net user Administrator $adminPass

# --- IP-Adresse ändern ---
# Hier wird die IP-Adresse auf 192.168.1.100 gesetzt
# und das Standardgateway auf 192.168.1.1
# Bitte passe die IP-Adresse und das Gateway an dein Netzwerk an
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "8.8.8.8","8.8.4.4"

# --- Hintergrundfarbe auf grün setzen ---
Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 0"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value ""
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# --- BGInfo herunterladen und aktivieren ---
$bginfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bginfoZip = "$env:TEMP\BGInfo.zip"
$bginfoPath = "$env:TEMP\BGInfo"
Invoke-WebRequest -Uri $bginfoUrl -OutFile $bginfoZip
Expand-Archive -Path $bginfoZip -DestinationPath $bginfoPath -Force
Start-Process -FilePath "$bginfoPath\Bginfo.exe"

# --- Neustart ---
Write-Host "Der PC wird in 10 Sekunden neu gestartet..."
Start-Sleep -Seconds 10
Restart-Computer -Force