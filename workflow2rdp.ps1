# Das Script benutzt FHEM um WOL Devices zu prüfen, zu starten und wenn alles verfügbar ist: wird eine RDP Verbindung gestartet
# Die WOl Devices haben je zwei userReadings smbRunning und rdpRunning die gesetzt werden, wenn die jeweiligen Ports verfügbar sind
# diese 3 Variablen müssen angepasst werden
$fhemurl = "http://192.168.x.x:8083" #Setup
$server = "ServerNameWOLDevice" #Setup
$station = "StationsNameWOLDevice" #Setup
# Das Script prüft eine bestimmtes Netzwerkverbindungsprofil
if ((Get-NetConnectionProfile).Name|? {$_ -match 'peer'}){
    "Wireguard ist verbunden"
    # falls nicht verfügbar fhemcl Script nachladen
    if (-not(Test-Path .\fhemcl.ps1)) {wget -OutFile .\fhemcl.ps1 https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.ps1}
    $check=(("list ${server} isRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
    if ($check -eq 'false'){
       Write-Output "Server $server wird gestartet, bitte warten"
       "set $server on;sleep ${server}:smbRunning:.1 wait${server};set $station on"|.\fhemcl.ps1 $fhemurl
    }
    Write-Output "Es wird auf den Start der Station $station gewartet."
    do {
       $check=(("list $station rdpRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
       Write-Progress -CurrentOperation "Warte auf Verfügbarkeit" ( "Station $station" )
       sleep 1
       }
    until ($check -eq '1')
    $ipaddr=(("list $station IP"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[1]    # lies die IP Adresse aus dem WOL Device
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:${ipaddr}" -Wait -WindowStyle Maximized
    ############################

    # "set $station off;sleep ${station}:isRunning:.false wait${station}; sleep 2; IF ([st_Rechner] eq 'off' and [Sicherung] eq 'beendet') (set $server off)"|.\fhemcl.ps1 $fhemurl
} else {Read-Host -Prompt "Zuerst mit Wireguard verbinden - ENTER drücken..."}
