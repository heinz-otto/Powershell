# --- Intel-Dienste vollständig entfernen ---
Write-Host "`n=== Intel-Dienste-Entferner ===`n"

# 1. Alle Intel-Dienste finden (normale Dienste)
$intelServices = Get-Service | Where-Object {
    $_.Name -like "*intel*" -or $_.DisplayName -like "Intel*"
}

# 2. Alle Intel-Treiber-Dienste finden
$intelDrivers = Get-WmiObject Win32_SystemDriver | Where-Object {
    $_.Name -like "*intel*" -or $_.DisplayName -like "Intel*"
}

if ($intelServices.Count -eq 0 -and $intelDrivers.Count -eq 0) {
    Write-Host "Keine Intel-Dienste gefunden."
    return
}

Write-Host "Gefundene Intel-Dienste:"
$intelServices | Select Name, DisplayName, Status | Format-Table -AutoSize
$intelDrivers  | Select Name, DisplayName, State  | Format-Table -AutoSize

# 3. Dienste stoppen und löschen
foreach ($svc in $intelServices) {
    Write-Host "`nEntferne Dienst: $($svc.Name)"

    # Stoppen
    Stop-Service $svc.Name -Force -ErrorAction SilentlyContinue

    # Löschen
    sc.exe delete $svc.Name | Out-Null

    # Registry-Rest entfernen
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Treiber-Dienste löschen
foreach ($drv in $intelDrivers) {
    Write-Host "`nEntferne Treiber-Dienst: $($drv.Name)"

    # Löschen
    sc.exe delete $drv.Name | Out-Null

    # Registry-Rest entfernen
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($drv.Name)"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n✔️ Alle Intel-Dienste wurden entfernt."
Write-Host "Bitte neu starten, damit Windows die Änderungen vollständig übernimmt."
