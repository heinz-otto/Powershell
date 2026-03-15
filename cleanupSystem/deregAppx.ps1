# ============================
# Ghost-AppX Deregistration Script
# ============================

$ghosts = @(
    "AppUp.IntelGraphicsExperience_1.100.5688.0_neutral_~8j3eq9eme6ctt",
    "AppUp.IntelNUCSoftwareStudio_1.44.25758.0_neutral~8j3eq9eme6ctt",
    "LGElectronics.LGMonitorApp_1.2602.502.0_neutral~cfnzzhwkr8z5w",
    "RealtekSemiconductorCorp.RealtekAudioControl_1.29.256.0_neutral~_dt26b99r8h8gj"
)

$repoPath = "C:\ProgramData\Microsoft\Windows\AppRepository\Packages"

foreach ($pkg in $ghosts) {
    $manifest = Join-Path $repoPath $pkg "\AppxManifest.xml"

    if (Test-Path $manifest) {
        Write-Host "Deregistriere Ghost-Paket: $pkg" -ForegroundColor Yellow
        Remove-AppxPackage -PackagePath $manifest -AllUsers -ErrorAction SilentlyContinue
    } else {
        Write-Host "Kein Manifest gefunden (bereits halb entfernt): $pkg" -ForegroundColor DarkGray
    }
}

Write-Host "AppX-Cache neu indizieren..." -ForegroundColor Cyan
Get-AppxPackage | Out-Null

Write-Host "WpnService neu starten..." -ForegroundColor Cyan
Stop-Service WpnService -Force
Start-Service WpnService

Write-Host "Deregistrierung abgeschlossen." -ForegroundColor Green
