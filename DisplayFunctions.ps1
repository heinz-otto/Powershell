 <#
.SYNOPSIS
    The script provide functions to set Display Scaling
.DESCRIPTION	
    The script provide functions to set Display Scaling
.EXAMPLE
    # switch to alternate Resolution for Fullscreen RemoteDesktop Session
    $ipaddr='192.168.x.x'
    Set-DisplayScaling -1
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:${ipaddr}" -Wait
    Set-DisplayScaling 0
.LINK
    https://github.com/heinz-otto/Powershell/
#>
function Set-DisplayScaling {
    # 0 ist immer der empfohlene Wert, von da aus plus minus in 1 Schritten 
    # Achtung! uint: 0 to 4294967295 , wenn $scaling negativ -> [uint32]::MaxValue + 1 + $scaling
    # -1 = 4294967295 , -2 = 4294967294
    # Beispiel 150% empfohlen
    # $scaling = -2 : 100% 
    # $scaling = -1 : 125% 
    # $scaling = 0 : 150% (default)
    # $scaling = 1 : 175% 
    # Beispiel 100% empfohlen
    # $scaling = 0 : 100% (default)
    # $scaling = 1 : 125% 
    # $scaling = 2 : 150% 
    # $scaling = 3 : 175% 
    param([int]$scaling = 0)
    # umrechnung in uint32
    if ($scaling -lt 0) {[uint32]$scale = [uint32]::MaxValue + 1 + $scaling} else {[uint32]$scale = $scaling}

$source = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
    $apicall = Add-Type -MemberDefinition $source -Name WinAPICall -Namespace SystemParamInfo -PassThru
    $apicall::SystemParametersInfo(0x009F, $scale, $null, 1) | Out-Null
}
function Get-DisplayResolution {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SystemInformation]::VirtualScreen
}
