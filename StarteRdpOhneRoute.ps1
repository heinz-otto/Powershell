########################### Das läuft
# Ohne Route da VPN Client
if ((Get-NetConnectionProfile).Name|? {$_ -match 'peer'}){
    "Wireguard ist verbunden"
    if (-not(Test-Path .\fhemcl.ps1)) {wget -OutFile .\fhemcl.ps1 https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.ps1}
    $fhemurl="http://192.168.178.104:8083"
    $server='ZADONIXS1'
    $station='Roentgen'
    $check=(("list ZADONIXS1 isRunning"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[3]
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
    $ipaddr=(("list $station IP"|.\fhemcl.ps1 $fhemurl).split()| where {$_})[1]
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:${ipaddr}" -Wait -WindowStyle Maximized
    ############################

    # "set $station off;sleep ${station}:isRunning:.false wait${station}; sleep 2; IF ([st_Rechner] eq 'off' and [Sicherung] eq 'beendet') (set $server off)"|.\fhemcl.ps1 $fhemurl
} else {Read-Host -Prompt "Zuerst mit Wireguard verbinden - ENTER drücken..."}