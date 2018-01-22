# Test für dot sourcing
# Sende WOL
# und warte bis IP erreichbar, Abruch nach x Durchläufen
Set-Location $PSScriptRoot
. .\SendWOLPacket.ps1 #-macstring "H340" -verbose 
. .\BalloonTipp.ps1
$x=15 # Abruch nach x Durchläufen

Send-WOL -mac '00:26:2D:00:10:91' -ip 192.168.178.255 
$i=0
while (!(Test-Connection 192.168.178.44 -Count 1 -quiet)){
    sleep(1)
    $i++
    write-verbose $i
    If ($i -gt $x) {
    Show–BalloonTip –Text 'NAS bitte per Hand starten, eventuell war Stromausfall' –Title 'Achtung' –Icon Warning –Timeout 15000
    exit
    }
}
Show–BalloonTip –Text 'NAS ist jetzt erreichbar' –Title 'Alles in Ordnung'

