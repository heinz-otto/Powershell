# Parameter
$savePATH = "c:\tools\scripts"
$saveFILE = "StartePraxis"
$ScriptWeb = "https://raw.githubusercontent.com/heinz-otto/Powershell/master/workflow2rdp.ps1"

# https://usefulscripting.network/powershell/file-dialog-with-powershell/
#[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
Add-Type -AssemblyName System.Windows.Forms
#https://www.mariotti.de/powershell-dialog/
Add-Type -AssemblyName Microsoft.VisualBasic

function Get-NewLineContent {
    param ( $ScriptContent,$LineToUpdate )

    $oldline = $ScriptContent | Select-String -Pattern $LineToUpdate | Select -First 1
    $OldString = ("$oldline"| Select-String -Pattern '".*"').Matches.Value -Replace ("`"","")
    $newvalue = [Microsoft.VisualBasic.Interaction]::InputBox("geben sie den neuen Wert ein", "Eingabe", $OldString)
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

# Script einlesen
$ScriptModified=Get-ScriptContent $ScriptWeb

# Alle Zeilen zum Ändern in ein Array
$array = $ScriptModified | Select-String -Pattern ".*#Setup"

# Zeilenweise ändern
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
