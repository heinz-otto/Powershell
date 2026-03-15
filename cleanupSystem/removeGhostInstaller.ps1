$paths = @(
  "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
  "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $paths) {
    Get-ChildItem $path | ForEach-Object {
        $display = $_.GetValue("DisplayName")
        $uninst = $_.GetValue("UninstallString")

        if ($display -and -not $uninst) {
            Write-Host "Entferne toten Eintrag: $display"
            Remove-Item $_.PsPath -Recurse -Force
        }
    }
}
