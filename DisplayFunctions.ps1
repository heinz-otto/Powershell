function Set-DisplayScaling {
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
