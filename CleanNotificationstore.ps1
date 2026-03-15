Stop-Service WpnService -Force
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Notifications" -Recurse -Force
Start-Service WpnService
