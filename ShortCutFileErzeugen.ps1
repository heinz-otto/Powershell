# Shortcut File Name erzeugen über Shell Object Startup Pfad ermitteln
$Startup = (New-Object -ComObject Shell.Application).NameSpace(0x07)
$ShortcutFile = $Startup.Self.Path + "\MeinLink.lnk"
#Powershell Pfad setzen
$TargetFile = "$env:SystemRoot\System32\\WindowsPowerShell\v1.0\powershell.exe"
# Shortcut erzeugen und Inhalte setzen
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Description = "Beschreibung"
$Shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.Arguments ="-WindowStyle Hidden &'$PSScriptRoot\StarteNAS.ps1'"
$Shortcut.Save()