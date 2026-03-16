# ================================
# COM+ Katalog Reparaturskript
# ================================

Write-Host "=== COM+ Reparatur wird gestartet ===" -ForegroundColor Cyan

# 1) Dienste stoppen
Write-Host "Stoppe Dienste..." -ForegroundColor Yellow
Stop-Service msiserver -Force -ErrorAction SilentlyContinue
Stop-Service COMSysApp -Force -ErrorAction SilentlyContinue

# 2) Besitz übernehmen
$catalogPath = "C:\Windows\System32\Com\Catalog"

Write-Host "Übernehme Besitz von $catalogPath ..." -ForegroundColor Yellow
takeown /f $catalogPath /r /d y | Out-Null
icacls $catalogPath /grant administrators:F /t | Out-Null

# 3) Löschen der COM+ Katalogdateien
Write-Host "Lösche COM+ Katalogdateien (*.clb)..." -ForegroundColor Yellow
Get-ChildItem "$catalogPath\*.clb" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# 4) Optional: QEMU-Reste entfernen
Write-Host "Entferne alte QEMU-Dienste..." -ForegroundColor Yellow
sc.exe delete "QEMU-GA" | Out-Null
sc.exe delete "QEMU Guest Agent" | Out-Null

# 5) Registry-Reste entfernen
Write-Host "Bereinige Registry..." -ForegroundColor Yellow
Remove-Item "HKLM:\SOFTWARE\QEMU Guest Agent" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Services\QEMU-GA" -Recurse -Force -ErrorAction SilentlyContinue

# 6) Abschluss
Write-Host ""
Write-Host "=== Reparatur abgeschlossen ===" -ForegroundColor Green
Write-Host "Bitte starte Windows jetzt neu." -ForegroundColor Green
