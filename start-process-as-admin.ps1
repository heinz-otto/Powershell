if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}
$zielnetz='192.168.12.0'
$router='192.168.56.27'
$prog="http://192.168.12.1"
# Route aktivieren
route add $zielnetz mask 255.255.255.0 $router
# Anwendung starten, 
Start-Process $prog -wait
# viele Anwendungen beenden den Aufrufprozess - dann diese Zeile aktivieren
Read-Host -Prompt "Route ins Netzwerk $zielnetz noch aktiv - eine Taste zum loeschen" #pause
# Route löschen 
route delete $zielnetz mask 255.255.255.0 $router
