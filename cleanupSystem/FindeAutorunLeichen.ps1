# --- Autostart-Leichen-Finder ---
# Sucht in allen typischen Autostart-Quellen nach Einträgen,
# deren Ziel-EXE nicht mehr existiert.

Write-Host "`n=== Autostart-Leichen-Scan ===`n"

$results = @()

# 1. Registry: Run / RunOnce
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Get-ItemProperty $path | ForEach-Object {
            $_.PSObject.Properties |
            Where-Object { $_.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider") } |
            ForEach-Object {
                $value = $_.Value
                if ($value -match '"([^"]+\.exe)"') {
                    $exe = $matches[1]
                } else {
                    $exe = $value
                }

                if ($exe -and -not (Test-Path $exe)) {
                    $results += [PSCustomObject]@{
                        Source = $path
                        Name   = $_.Name
                        Target = $exe
                    }
                }
            }
        }
    }
}

# 2. Autostart-Ordner
$startupFolders = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($folder in $startupFolders) {
    if (Test-Path $folder) {
        Get-ChildItem $folder -File | ForEach-Object {
            $shortcut = $_.FullName
            $wsh = New-Object -ComObject WScript.Shell
            $target = $wsh.CreateShortcut($shortcut).TargetPath

            if ($target -and -not (Test-Path $target)) {
                $results += [PSCustomObject]@{
                    Source = $folder
                    Name   = $_.Name
                    Target = $target
                }
            }
        }
    }
}

# 3. Geplante Tasks
$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue
foreach ($task in $tasks) {
    foreach ($action in $task.Actions) {
        if ($action.Execute -and $action.Execute -match "\.exe$") {
            if (-not (Test-Path $action.Execute)) {
                $results += [PSCustomObject]@{
                    Source = "Scheduled Task: $($task.TaskName)"
                    Name   = $action.Execute
                    Target = $action.Execute
                }
            }
        }
    }
}

# Ausgabe
if ($results.Count -eq 0) {
    Write-Host "Keine Autostart-Leichen gefunden."
} else {
    Write-Host "`nGefundene Autostart-Leichen:`n"
    $results | Format-Table -AutoSize
}
