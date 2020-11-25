$A = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-command C:\Scripts\startwsl.ps1"
$T = New-ScheduledTaskTrigger -AtStartup
$P = New-ScheduledTaskPrincipal -UserID "otto" -LogonType S4U -Id Author -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask StartWslPP -InputObject $D