 <#
.SYNOPSIS
	The script will start server and workstation on behalf of FHEM
.DESCRIPTION	
    Workflow: Start Server / warten / Start Station / warten / verbinde mit RDP
    Das Script benutzt FHEM um WOL Devices zu pruefen, zu starten und wenn alles verfuegbar ist: wird eine RDP Verbindung gestartet.
    Die WOl Devices haben je zwei userReadings smbRunning und rdpRunning die gesetzt werden, wenn die jeweiligen Ports verfuegbar sind.
.EXAMPLE
    configure, save the script and simpel run it
.LINK
    https://github.com/heinz-otto/Powershell/edit/master/workflow2rdp.ps1
#>

# diese 3 Variablen muessen angepasst werden
$fhemurl = "http://192.168.x.x:8083" #Setup
$server = "ServerNameWOLDevice" #Setup
$station = "StationsNameWOLDevice" #Setup
$width = "1920" #Setup
$height = "1080" #Setup


$ConnectionProfilePattern = 'peer'

# For message box
Add-Type -AssemblyName System.Windows.Forms

# Das Script prueft auf ein bestehendes Netzwerkverbindungsprofil
if ((Get-NetConnectionProfile).InterfaceAlias|? {$_ -match $ConnectionProfilePattern}){
    Write-Output "Netzwerk ist verbunden"
    # falls nicht verfuegbar fhemcl Script nachladen
    if (-not(Test-Path .\fhemcl.ps1)) {wget -OutFile .\fhemcl.ps1 https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.ps1}
    $check=(("list ${server} isRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
    if ($check -eq 'false'){
       Write-Output "Server $server wird gestartet. Sobald dieser verfuegbar ist wird die Station $station gestartet"
       "set $server on;sleep ${server}:smbRunning:.1 wait${server};set $station on"|.\fhemcl.ps1 $fhemurl
       #sleep 2
       for($i = 0; $i -le 100; $i++) { 
          Write-Progress -Activity "Server $server startet" -PercentComplete $i -Status "warte $($i)" 
          $check=(("list $server smbRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
          Sleep 1;
          if ($check -eq '1'){
             Write-Output "Serverstart $server hat $i sec gedauert"
             break
          }
       }
    } else {
       Write-Output "Server $server ist schon aktiv. Station $station wird geprueft"
       $check=(("list ${station} isRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
       if ($check -eq 'false'){
          Write-Output "Station $station wird gestartet, bitte warten"
          "set $station on"|.\fhemcl.ps1 $fhemurl
       } else {Write-Output "Station $station schon aktiv"}
    }
    
    for($i = 0; $i -le 100; $i++) { 
       Write-Progress -Activity "Station $station startet" -PercentComplete $i -Status "warte $($i)" 
       $check=(("list $station rdpRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
       Sleep 1;
       if ($check -eq '1'){
          Write-Output "Stationstart $station hat $i sec gedauert"
          break
       }
    }
    if ($i -gt 99) {write-output "Der Start von Station $station ist misslungen"}
 
    sleep 2
    $ipaddr=(("list $station IP"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[1]    # lies die IP Adresse aus dem WOL Device
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:${ipaddr} /h:${height} /w:${width}" -Wait 
    
    # "set $station off;sleep ${station}:isRunning:.false wait${station}; sleep 2; IF ([st_Rechner] eq 'off' and [Sicherung] eq 'beendet') (set $server off)"|.\fhemcl.ps1 $fhemurl
} else {
   # Read-Host -Prompt "Zuerst mit Wireguard verbinden - ENTER druecken..."
   $result = [System.Windows.Forms.MessageBox]::Show("erst Wiregurad verbinden", "Netzwerkverbindung", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}
