# --- PhoneExperienceHost aus WinSxS wiederherstellen ---

Write-Host "`n=== Wiederherstellung von PhoneExperienceHost ===`n"

# Zielordner
$target = "C:\Windows\SystemApps\Microsoft.Windows.PhoneExperienceHost_cw5n1h2txyewy"

# 1. WinSxS-Ordner suchen
Write-Host "Suche WinSxS-Quelle..."
$source = Get-ChildItem "C:\Windows\WinSxS" -Directory |
    Where-Object { $_.Name -like "*phoneexperiencehost*" } |
    Sort-Object Name -Descending |
    Select-Object -First 1

if (-not $source) {
    Write-Host "❌ Keine passende WinSxS-Version gefunden."
    return
}

Write-Host "Gefundene Quelle: $($source.FullName)"

# 2. Zielordner neu anlegen
if (-not (Test-Path $target)) {
    Write-Host "Erstelle Zielordner..."
    New-Item -ItemType Directory -Path $target | Out-Null
}

# 3. Dateien kopieren
Write-Host "Kopiere Dateien..."
Copy-Item "$($source.FullName)\*" $target -Recurse -Force

# 4. App neu registrieren
$manifest = Join-Path $target "AppXManifest.xml"

if (Test-Path $manifest) {
    Write-Host "Registriere App..."
    Add-AppxPackage -DisableDevelopmentMode -Register $manifest
    Write-Host "`n✔️ PhoneExperienceHost erfolgreich wiederhergestellt!"
} else {
    Write-Host "❌ Manifest nicht gefunden – Kopie unvollständig."
}
