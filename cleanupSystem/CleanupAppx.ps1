# ============================
# Ghost-AppX Cleanup Script
# ============================

Write-Host "Starte Bereinigung defekter AppX-Pakete..." -ForegroundColor Cyan

# Liste der defekten Pakete (aus deiner Analyse)
$ghosts = @(
    "1527c705-839a-4832-9118-54d4Bd6a0c89_10.0.15063.447_neutral_neutral_cw5n1h2txyewy",
    "aimgr_0.20.18.0_x64__8wekyb3d8bbwe",
    "aimgr_0.20.40.0_x64__8wekyb3d8bbwe",
    "aimgr_0.20.41.0_x64__8wekyb3d8bbwe",
    "AppUp.IntelGraphicsExperience_1.100.5688.0_neutral_split.language-de_8j3eq9eme6ctt",
    "AppUp.IntelGraphicsExperience_1.100.5688.0_neutral_split.scale-100_8j3eq9eme6ctt",
    "AppUp.IntelGraphicsExperience_1.100.5688.0_neutral_split.scale-150_8j3eq9eme6ctt",
    "AppUp.IntelGraphicsExperience_1.100.5688.0_neutral_~8j3eq9eme6ctt",
    "AppUp.IntelNUCSoftwareStudio_1.44.25758.0_neutral~8j3eq9eme6ctt",
    "LGElectronics.LGMonitorApp_1.2602.502.0_neutral_split.scale-100_cfnzzhwkr8z5w",
    "LGElectronics.LGMonitorApp_1.2602.502.0_neutral_split.scale-150_cfnzzhwkr8z5w",
    "LGElectronics.LGMonitorApp_1.2602.502.0_neutral~cfnzzhwkr8z5w",
    "RealtekSemiconductorCorp.RealtekAudioControl_1.29.256.0_neutral_split.scale-100_dt26b99r8h8gj",
    "RealtekSemiconductorCorp.RealtekAudioControl_1.29.256.0_neutral~_dt26b99r8h8gj"
)

$repoPath = "C:\ProgramData\Microsoft\Windows\AppRepository\Packages"

foreach ($pkg in $ghosts) {
    $path = Join-Path $repoPath $pkg
    if (Test-Path $path) {
        Write-Host "Lösche: $pkg" -ForegroundColor Yellow
        Remove-Item $path -Recurse -Force
    } else {
        Write-Host "Nicht gefunden (bereits entfernt): $pkg" -ForegroundColor DarkGray
    }
}

Write-Host "Bereinige AppX-Cache..." -ForegroundColor Cyan
Get-AppxPackage | Out-Null

Write-Host "Starte WpnService neu..." -ForegroundColor Cyan
Stop-Service WpnService -Force
Start-Service WpnService

Write-Host "Bereinigung abgeschlossen." -ForegroundColor Green
