wsl -u fhem -d debian -e bash /mnt/c/scripts/start.sh
$cAddr=(wsl hostname -I).Trim()    # entferne Leerzeichen am Ende
$ports=8083,1883                   # Array mit allen Ports
if (netsh interface portproxy show all){netsh interface portproxy reset}
Foreach ($port in $ports){
   netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$cAddr
}
Set-NetFirewallRule -DisplayName 'WSL 2 Firewall Unlock' -LocalPort $ports