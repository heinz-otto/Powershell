<#
.SYNOPSIS
    The script is a kind of setup for a script downloaded from Web
.DESCRIPTION
    Im heruntergeladenem Script werden Zeilen mit #Setup gesucht und die Werte der Variablen werden neu gesetzt. 
    Das Script wird lokal gespeichert und ein Link auf dem Desktop erzeugt.
.EXAMPLE
    Starte dieses Script z.B. mit dieser Kommandozeile - windows+r
.EXAMPLE 
    powershell -nop -c (Invoke-WebRequest -Uri https://raw.githubusercontent.com/heinz-otto/Powershell/master/ChangeVariableInsideScript.ps1).content|powershell -
.LINK
    https://github.com/heinz-otto/Powershell/
    https://www.mariotti.de/powershell-dialog/
    https://www.netspi.com/blog/technical/network-penetration-testing/15-ways-to-bypass-the-powershell-execution-policy/
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# Parameter
$savePATH = "c:\tools\scripts"
$saveFILE = "StartePraxis"
$ScriptWeb = "https://raw.githubusercontent.com/heinz-otto/Powershell/master/workflow2rdp.ps1"
$savePATH = [Microsoft.VisualBasic.Interaction]::InputBox("Pfad Script", "Skriptkonfiguration", $savePATH)
$saveFILE = [Microsoft.VisualBasic.Interaction]::InputBox("Dateiname Script", "Skriptkonfiguration", $saveFILE)
$ScriptWeb = [Microsoft.VisualBasic.Interaction]::InputBox("WEB URL Script", "Skriptkonfiguration", $ScriptWeb)

# Functions
function Get-NewLineContent {
    param ( $ScriptContent,$LineToUpdate )

    $oldline = $ScriptContent | Select-String -Pattern $LineToUpdate | Select -First 1
    $InputBoxHeader = "Neuer Wert für " + ("$oldline".Split('#')[1]).Split(' ')[1] + " ?"
    $OldString = ("$oldline"| Select-String -Pattern '".*"').Matches.Value -Replace ("`"","")
    $newvalue = [Microsoft.VisualBasic.Interaction]::InputBox("$InputBoxHeader", "Konfiguriere Skript $saveFILE", $OldString)
    #$newvalue = Read-Host "$oldline - geben sie den neuen Wert ein für $OldString "
    $newline = "$oldline".Replace("$OldString","$newvalue").Split('#')[0]
    $ScriptContent.Replace("$oldline","$newline") 
}

function Get-ScriptContent {
   param ( $ScriptWeb )

   $Script = [System.IO.Path]::GetTempFileName()
   $webobjekt=Invoke-WebRequest -Uri $ScriptWeb -OutFile $Script
   Get-Content $Script
   Remove-Item $Script
}

function SaveScript {

  if (!(Test-Path $savePATH)) {New-Item -Path $savePATH -ItemType Directory}
  $saveDlg = New-Object -Typename System.Windows.Forms.SaveFileDialog
  $saveDlg.InitialDirectory = $savePATH
  $saveDlg.Filter = "Powershell files (*.ps1)|*.ps1"
  $saveDlg.DefaultExt = 'ps1'
  $saveDlg.FileName = $saveFILE
  $saveDlg.ShowDialog()
  $ScriptModified | Out-File $saveDlg.FileName
  get-item $saveDlg.FileName
}

function CreateLinkOnDesktop {
  param ( $file )

  $WshShell = New-Object -comObject WScript.Shell;
  $shortcut=$WshShell.CreateShortcut("$Home\Desktop\$($file.BaseName).lnk");
  $shortcut.TargetPath="PowerShell.exe";
  $shortcut.Arguments = '-ExecutionPolicy Bypass -File '+ $file.FullName
  $shortcut.WorkingDirectory = $file.DirectoryName
  $shortcut.Save();
}

# Main
# Script einlesen
$ScriptModified=Get-ScriptContent $ScriptWeb

# Alle Zeilen zum Ändern in ein Array und zeilenweise aendern
$array = $ScriptModified | Select-String -Pattern ".*#Setup"|Select-String -Pattern "^\s*#" -NotMatch
foreach ($line in $array){
  $linesearch="$line".Split('$| |=')[1]+".*#Setup"
  $ScriptModified = Get-NewLineContent $ScriptModified "$linesearch"
}

# Falls es Zeilen zum Änderungen gab - speichern und Desktop Link erzeugen
if ($array.Length -gt 0) {
   $file = $(SaveScript)
   # Erzeuge Icon auf dem Desktop
   CreateLinkOnDesktop $file
}
