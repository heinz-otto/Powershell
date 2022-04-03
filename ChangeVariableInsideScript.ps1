########

$savePATH = "c:\tools\scripts"
$saveFILE = "StartePraxis"

function Get-NewLineContent {
        param (
        $ScriptContent,$LineToUpdate
    )

    $oldline = $ScriptContent |  Select-String -Pattern $LineToUpdate | Select -First 1
    $OldString = ("$oldline"| Select-String -Pattern '".*"').Matches.Value -Replace ("`"","")
    $newvalue = Read-Host "$oldline - geben sie den neuen Wert ein für $OldString "
    $newline = "$oldline".Replace("$OldString","$newvalue").Split('#')[0]
    $ScriptContent.Replace("$oldline","$newline") 
}

Add-Type -AssemblyName System.Windows.Forms
# Script einfach laden $Script='C:\tools\scripts\StarteRDPSession.ps1'
# Auswahldialog
$caption = "Choose Action";
$message = "Wie soll das Skript geladen werden?";
$aktion0 = new-Object System.Management.Automation.Host.ChoiceDescription "&loadScriptDialog","loadScriptDialog";
$aktion1 = new-Object System.Management.Automation.Host.ChoiceDescription "&loadScriptFromWeb","loadScriptFromWeb";
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($aktion0,$aktion1);
$answer = $host.ui.PromptForChoice($caption,$message,$choices,0)
switch ($answer){
    0 {
    #loadScriptDialog
      $openDlg = New-Object -Typename System.Windows.Forms.OpenFileDialog
      $openDlg.ShowDialog()
      $Script=$openDlg.FileName
      $ScriptModified=Get-Content $Script
    }
    1 {
    #loadScriptFromWeb
      $Script='temp.txt'
      $ScriptWeb="https://raw.githubusercontent.com/heinz-otto/Powershell/master/workflow2rdp.ps1"
      $webobjekt=Invoke-WebRequest -Uri $ScriptWeb -OutFile $Script
      $ScriptModified=Get-Content $Script
      Remove-Item $Script
    }
}

# Alle Zeilen zum Ändern in ein Array
$array = $ScriptModified | Select-String -Pattern ".*#Setup"

# Zeilenweise ändern
foreach ($line in $array){
  $linesearch="$line".Split('$| |=')[1]+".*#Setup"
  $ScriptModified = Get-NewLineContent $ScriptModified "$linesearch"
}
# Falls es Änderungen gab - speichern
if ($array.Length -gt 0) {
    if (!(Test-Path $savePATH)) {New-Item -Path $savePATH -ItemType Directory}
    $saveDlg = New-Object -Typename System.Windows.Forms.SaveFileDialog
    $saveDlg.InitialDirectory = $savePATH
    $saveDlg.DefaultExt = 'ps1'
    $saveDlg.FileName = $saveFILE
    $saveDlg.ShowDialog()
    
    $ScriptModified | Out-File $saveDlg.FileName
}

# Erzeuge Icon auf dem Desktop
#$file = get-item 'C:\Users\heinz\OneDrive\Dokumente\workfow2rdp.ps1'
$file = get-item $saveDlg.FileName
$WshShell = New-Object -comObject WScript.Shell;
$shortcut=$WshShell.CreateShortcut("$Home\Desktop\$($file.BaseName).lnk");
$shortcut.TargetPath="PowerShell.exe";
$shortcut.Arguments = '-ExecutionPolicy Bypass -File '+ $file.FullName
$shortcut.WorkingDirectory = $file.DirectoryName
$shortcut.Save();
