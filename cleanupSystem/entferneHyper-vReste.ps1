# --- Hyper-V-Dienste vollständig entfernen ---
Write-Host "`n=== Hyper-V-Dienste-Entferner ===`n"

# Typische Hyper-V Dienstnamen
$hvNames = @(
    "vmcompute",          # Hyper-V Host Compute Service
    "vmms",               # Hyper-V Virtual Machine Management
    "vmic*",              # Hyper-V Integration Services
    "vhdsvc",             # Virtual Disk Service
    "HvHost",             # Hyper-V Host Service
    "icssvc",             # Integration Component Service
    "vmicvss", "vmicguestinterface", "vmicheartbeat",
    "vmickvpexchange", "vmicshutdown", "vmictimesync"
)

# 1. Normale Dienste finden
$hvServices = Get-Service | Where-Object {
    $name = $_.Name.ToLower()
    $hvNames | ForEach-Object { $name -like $_.ToLower() }
}

# 2. Treiber-Dienste finden
$hvDrivers = Get-WmiObject Win32_SystemDriver | Where-Object {
    $_.Name -like "hv*" -or $_.Name -like "vmbus" -or $_.Name -like "vmstor*" -or $_.Name -like "storvsc"
}

if ($hvServices.Count -eq 0 -and $hvDrivers.Count -eq 0) {
    Write-Host "Keine Hyper-V-Dienste gefunden."
    return
}

Write-Host "Gefundene Hyper-V-Dienste:"
$hvServices | Select Name, DisplayName, Status | Format-Table -AutoSize

Write-Host "`nGefundene Hyper-V-Treiber:"
$hvDrivers | Select Name, DisplayName, State | Format-Table -AutoSize

# 3. Dienste stoppen und löschen
foreach ($svc in $hvServices) {
    Write-Host "`nEntferne Dienst: $($svc.Name)"

    Stop-Service $svc.Name -Force -ErrorAction SilentlyContinue
    sc.exe delete $svc.Name | Out-Null

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Treiber-Dienste löschen
foreach ($drv in $hvDrivers) {
    Write-Host "`nEntferne Treiber-Dienst: $($drv.Name)"

    sc.exe delete $drv.Name | Out-Null

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($drv.Name)"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n✔️ Alle Hyper-V-Dienste wurden entfernt."
Write-Host "Bitte neu starten, damit Windows die Änderungen vollständig übernimmt."
