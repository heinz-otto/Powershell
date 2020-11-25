<#
.SYNOPSIS
	This Script will setup start WSL during host startup
.DESCRIPTION	
    This Script will make a special setup for starting WSL and a linux job every time when Windows is starting
.EXAPMLE
    execute the script only: SetupStartWsl.ps1
.LINK
    https://heinz-otto.blogspot.com/2020/11/wsl-windows-linux-wie-macht-man-das.html
#>
### Some configuration variables
$fileS='c:\scripts\start.sh'      # shell scriptname
$fileP='c:\scripts\startwsl.ps1'  # powershell scriptname
$FWRname='WSL 2 Firewall Unlock'  # Firewall Name
$userID='otto'                    # UserID for Task 
$taskname='StartWslPP'            # Name for Task
$ports=8083,1883                  # ports for first Rule

### 1. create the script for linux job with 'here string' and strip the Windowsstyle newline 
###
@"
cd /opt/fhem
perl fhem.pl fhem.cfg
"@ | Out-File -Encoding ASCII $fileS
((Get-Content $fileS) -join "`n") + "`n" | Set-Content -NoNewline $fileS
### 2. create in a similar way the Powershellscript wich will used from the taskscheduler
###

@'
wsl -u fhem -d debian -e bash /mnt/c/scripts/start.sh
$cAddr=(wsl hostname -I).Trim()    # entferne Leerzeichen am Ende
$ports=8083,1883                   # Array mit allen Ports
if (netsh interface portproxy show all){netsh interface portproxy reset}
Foreach ($port in $ports){
   netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$cAddr
}
Set-NetFirewallRule -LocalPort $ports 
'@ + @"
-DisplayName "$FWRname"
"@ | Out-File -Encoding ASCII $fileP
###
### 3. Create Basic Firewall Rules for the portforwarding to wsl
###
if (-not(Get-NetFirewallRule -DisplayName "$FWRname")){
    New-NetFireWallRule -DisplayName "$FWRname" -Direction Outbound -LocalPort $ports -Action Allow -Protocol TCP
    New-NetFireWallRule -DisplayName "$FWRname" -Direction Inbound -LocalPort $ports -Action Allow -Protocol TCP
} else {Set-NetFirewallRule -LocalPort $ports -DisplayName "$FWRname"}
###
### Last: register a Task wich will execute the second PS Script every time starting up the Windows Host System
$A = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-command $fileP"
$T = New-ScheduledTaskTrigger -AtStartup
$P = New-ScheduledTaskPrincipal -UserID $userID -LogonType S4U -Id Author -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
if (-not(Get-ScheduledTask "$taskname*")) {Register-ScheduledTask "$taskname" -InputObject $D} else {Set-ScheduledTask "$taskname" -InputObject $D}
