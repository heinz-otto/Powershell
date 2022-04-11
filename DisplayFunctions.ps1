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
    param([uint32]$scaling = 0)
$source = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
    $apicall = Add-Type -MemberDefinition $source -Name WinAPICall -Namespace SystemParamInfo –PassThru
    # umrechnung in uint32
    if ($scaling -lt 0) {[uint32]$scaling = [uint32]::MaxValue + 1 + $scaling}
    $apicall::SystemParametersInfo(0x009F, $scaling, $null, 1) | Out-Null
}
function Get-DisplayResolution {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SystemInformation]::VirtualScreen
}
$ipaddr='lpkw11'
Set-DisplayScaling 1
Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:${ipaddr}" -Wait
Set-DisplayScaling 0
