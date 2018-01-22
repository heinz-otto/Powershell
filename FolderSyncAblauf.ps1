Set-Location $PSScriptRoot
$UserName= "melaniedonix@t-online.de"
$PWDFile=".\PASSWORDM.txt"
$Share="\\webdav.magentacloud.de@SSL\DavWWWRoot"
$Drive="T"
$SourceFolder = "S:\MagentaCLOUD\Sicherung"
$DestFolder = "S:\SicherungNeu"
$MagentaFolderLocal = "S:\MagentaCLOUD"

#Credential aus Passwort Datei und Username erzeugen
$encrypted = Get-Content $PWDFile | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($UserName, $encrypted)

.\SetDeviceFhem.ps1 -Hostname "192.168.100.119" -Name "Sicherung" -Event "gestartet"

#Netzlaufwerk verbinden
New-PSDrive -Name $Drive -Root $Share -PSProvider FileSystem -Credential $credential

#Verzeichnisse synchronisieren
.\Sync-Folder.ps1 -SourceFolder ($Drive + ":\") -TargetFolder $MagentaFolderLocal

.\SetDeviceFhem.ps1 -Hostname "192.168.100.119" -Name "Sicherung" -Event "synchronisiert"

$SicherungStat = get-childitem -r $SourceFolder | Measure-Object -Property length -sum 

#.\SetDeviceFhem.ps1 -Hostname "192.168.100.119" -Name "Sicherung" -Event $sumtxt
"setreading","Sicherung","lastTransferCount",$SicherungStat.count |.\SetDeviceFhem.ps1 -Hostname "192.168.100.119"
"setreading","Sicherung","lastTransferSizeB",$SicherungStat.sum |.\SetDeviceFhem.ps1 -Hostname "192.168.100.119"

#Synchronisierte Dateien Überprüfen
$Return = .\FolderCompare.ps1 -LeftHashFile "S:\MagentaCloud\Scripts\LeftsideHash*.txt" -RightDir "S:\MagentaCLOUD\Sicherung"

if ($Return -eq 0) {
    .\SetDeviceFhem.ps1 -Hostname "192.168.100.119" -Name "Sicherung" -Event "geprueft"
        
    $FilesSicherung = Import-Clixml ($MagentaFolderLocal + "\Scripts\Sicherung.xml")
    $FilesHash = Import-Clixml ($MagentaFolderLocal + "\Scripts\Hashfiles.xml")
    
    # Create Directorys
    $FilesSicherung | where {$_.attributes -match "Directory"}| %{
        $newdir = $_.fullname.Replace("Z:\Sicherung",$DestFolder)
        If (-not (Test-Path $newdir)) { 
        write-verbose "Erzeuge Pfad $newdir"
        md $newdir 
        }
      }
    
    # Move Items
    $FilesSicherung | where {$_.attributes -notmatch "Directory"} |% {move-item $_.Fullname.Replace("Z:\Sicherung",$Sourcefolder) $_.Fullname.Replace("Z:\Sicherung",$Destfolder)} 
    $FilesHash | % {$_.Fullname.Replace("Z:",$MagentaFolderLocal)}|Remove-Item 

    # Remove Online Files
    $Files = $FilesSicherung + $FilesHash
    $Files | where {$_.attributes -notmatch "Directory"} |% {$_.Fullname.Replace("Z",$Drive)} |Remove-Item 
    
    }

.\SetDeviceFhem.ps1 -Hostname "192.168.100.119" -Name "Sicherung" -Event "beendet"
Remove-PSDrive -name $Drive
Write-Verbose "Laufwerk $Drive entfernt"