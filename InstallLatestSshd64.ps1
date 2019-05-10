# need WMF 5.1 
if ($PSVersionTable.PSVersion.tostring(2) -lt 5.1){
    write-output "Mindestens WMF 5.1 erforderlich"
    write-output "Powershell Version "$PSVersionTable.PSVersion.tostring(4)
    exit
  }
# get the url for latest sshd, Code from https://github.com/PowerShell/Win32-OpenSSH/wiki/How-to-retrieve-links-to-latest-packages
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
$request = [System.Net.WebRequest]::Create($url)
$request.AllowAutoRedirect=$false
$response=$request.GetResponse()
$url = $([String]$response.GetResponseHeader("Location")).Replace('tag','download') + '/OpenSSH-Win64.zip'
# Download, expand and install
Invoke-WebRequest $url -OutFile openssh.zip
Expand-Archive .\openssh.zip ${Env:ProgramFiles}
cd "${Env:ProgramFiles}\OpenSSH-Win64\"
.\install-sshd.ps1
# Open Firewall for Port 22
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
# Patch sshd config to allow administrators Group public Key logon
$Quelle="${Env:ProgramData}\ssh\sshd_config"
$Inhalt = Get-Content $Quelle
$Inhalt|foreach {if ($_ -match "administrators") {$Inhalt[$_.readcount-1]=$_.Insert(0,"#")}}
set-Content $Quelle $Inhalt
# Start Service and configure autostart
Start-Service -Name sshd
Set-Service -Name sshd -StartupType automatic
