### This Script will make a special setup for starting WSL and a linux job every time when Windows is starting
### first create the script for linux job with here string and strip the Windowsstyle newline 
###
$file='c:\scripts\start.sh'
@"
cd /opt/fhem
perl fhem.pl fhem.cfg
"@ | Out-File -Encoding ASCII $file
((Get-Content $file) -join "`n") + "`n" | Set-Content -NoNewline $file
### second create in a similar way the Powershellscript wich will used from the taskscheduler
###
$file='c:\scripts\startwsl.ps1'
@"
wsl -u fhem -d debian -e bash /mnt/c/scripts/start.sh
$cAddr=(wsl hostname -I).Trim()    # entferne Leerzeichen am Ende
$ports=8083,1883                   # Array mit allen Ports
if (netsh interface portproxy show all){netsh interface portproxy reset}
Foreach ($port in $ports){
   netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$cAddr
}
Set-NetFirewallRule -DisplayName 'WSL 2 Firewall Unlock' -LocalPort $ports
"@ | Out-File -Encoding ASCII $file
###
### Create Basic Firewall Rules for the portforwarding to wsl
###
$ports=8083,1883
New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports -Action Allow -Protocol TCP
New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports -Action Allow -Protocol TCP
###
### Last Step register a Task wich will execute the PS Script every time starting up the Windows Host System
$userID='otto'
$taskname='StartWslPP'
$A = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-command $file"
$T = New-ScheduledTaskTrigger -AtStartup
$P = New-ScheduledTaskPrincipal -UserID $userID -LogonType S4U -Id Author -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask $taskname -InputObject $D
