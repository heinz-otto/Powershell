function Set-DisplayScaling {
    # 0 ist immer der empfohlene Wert, von da aus plus minus in 1 Schritten
    # int: –2147483648 to 2147483647 uint: 0 to 4294967295
    # -1 = 4294967295
    # -2 = 4294967294
    # -3 = 4294967293
    # $scaling = 0 : 100% (default)
    # $scaling = 1 : 125% 
    # $scaling = 2 : 150% 
    # $scaling = 3 : 175% 
    param($scaling = 0)
$source = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
    $apicall = Add-Type -MemberDefinition $source -Name WinAPICall -Namespace SystemParamInfo –PassThru
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
