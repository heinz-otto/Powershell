<# 
  .SYNOPSIS  
    Send a WOL packet to a broadcast address
  .DESCRIPTION
    The Script could be called with the Parameter -MacString then could also be used a Table with Device Names
    If the Script is called without any Parameter, only the Function is available
  .PARAMETER -MacString
   The MAC address of the device that need to wake up
  .EXAMPLE 
   SendWOLPacket -MacString 'H340' 
  .EXAMPLE 
   . .\SendWOLPacket.ps1  
#>

Param ($MacString)
 
$Table=@{
    H340      ='00:26:2D:00:10:91';
    lsk2012   ='78:24:AF:43:AC:E5';
    Desktop   ='00-00-00-00-00-1B';
    Laptop    ='00-00-00-00-00-18';
    Playroom  ='00-00-00-00-00-5C';
    Betty     ='00-00-00-00-00-32';
    gr8       ='00-00-00-00-00-D7'
}

function Send-WOL
{
<# 
  .SYNOPSIS  
    Send a WOL packet to a broadcast address
  .PARAMETER mac
   The MAC address of the device that need to wake up
  .PARAMETER ip
   The IP address where the WOL packet will be sent to
  .EXAMPLE 
   Send-WOL -mac 00:11:32:21:2D:11 -ip 192.168.8.255 
  .LINK
   https://gallery.technet.microsoft.com/scriptcenter/Send-WOL-packet-using-0638be7b
#>

[CmdletBinding()]
param(
[Parameter(Mandatory=$True,Position=1)]
[string]$mac,
[string]$ip="255.255.255.255", 
[int]$port=9
)
$broadcast = [Net.IPAddress]::Parse($ip)
Write-Verbose "Using MAC string $mac"
Write-Verbose "Using Broadcast $broadcast"

$mac=(($mac.replace(":","")).replace("-","")).replace(".","")
$target=0,2,4,6,8,10 | % {[convert]::ToByte($mac.substring($_,2),16)}
$packet = (,[byte]255 * 6) + ($target * 16)
Write-Verbose "Packet $packet"

$UDPclient = new-Object System.Net.Sockets.UdpClient
$UDPclient.Connect($broadcast,$port)
[void]$UDPclient.Send($packet, 102) 

}

if ($MacString){
    
    If ($Table.ContainsKey($MacString)) {$MacString=$Table[$MacString]}

    If ($MacString -NotMatch '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
        Throw 'Mac address must be 6 hex bytes separated by : or -'
    }

    Send-WOL -mac $MacString 
 }