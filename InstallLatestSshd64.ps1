<#
.SYNOPSIS
    This Script will be install or upgrade OpenSSH Server on Windows 2012 and 2016
.DESCRIPTION
    The process is 4 steps straight away, no dialog.
    1. The Version of WMF is checked (5.1) and updated if nessesary.
    2. The SSH Server will be downloaded and installed.
    3. The Firewall will be configured properly, open port 22.
    4. The public Key Logon for Administrators on Windows 2012 will be patched.
    see also: https://heinz-otto.blogspot.com/2019/05/windows-von-fhem-aus-steuern.html
.EXAMPLE
    simply start the Script within powershell, no parameters. 
.NOTES
    May be, some links will be broken in the Future. (May 2019)
#>
$w32caption=(Get-WmiObject -class Win32_OperatingSystem).Caption
# need WMF 5.1, try to install on Windows Server 2012
if ($PSVersionTable.PSVersion.tostring(2) -lt 5.1){
    write-output "No WMF 5.1, search Windows Server 2012"
    # Get the OS Version
    if ($w32caption -match "Windows Server 2012 R2") {$Spattern="W2K12R2-"}
    elseif ($w32caption -match "Windows Server 2012") {$Spattern="W2K12-"}
    else {Write-Output "Setup WMF5 manually";exit}
    write-output "Windows Server 2012 detected $Spattern"
    # May be this links below will be broken in the future
    # On this page https://gist.github.com/mgreenegit/b80ddd089677f92f56f5
    # is a Script to determine the direkt links
    if ($Spattern -eq "W2K12R2-") {$directURL="https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"}
    elseif ($Spattern -eq "W2K12-"){$directURL="https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu"}
    $download = invoke-webrequest $directURL -OutFile $env:Temp\wmf5latest.msu
    # Install quietly with no reboot
    write-output "$env:Temp\wmf5latest.msu will being installed, needs some time"
    if (test-path $env:Temp\wmf5latest.msu) {
      start -wait $env:Temp\wmf5latest.msu -argumentlist '/quiet /norestart'
      write-output "$env:Temp\wmf5latest.msu installed"
      }
    else { throw 'the update file is not available at the specified location' }
    # Clean up
    Remove-Item $env:Temp\wmf5latest.msu
    write-output "WMF 5 installed, reboot is needed! Reboot now and run Script simply again."
    write-output "Type Restart-Computer now."
    exit
  }
# only for Server 2012 or 2016
if (-not ($w32caption -match "2012") -and -not ($w32caption -match "2016")) {
    write-output "is not any Version of Server 2012 or 2016 - try another method"
    exit
}
write-output "get latest sshd"
# get the url for latest sshd, Code from https://github.com/PowerShell/Win32-OpenSSH/wiki/How-to-retrieve-links-to-latest-packages
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
$request = [System.Net.WebRequest]::Create($url)
$request.AllowAutoRedirect=$false
$response=$request.GetResponse()
$url = $([String]$response.GetResponseHeader("Location")).Replace('tag','download') + '/OpenSSH-Win64.zip'
write-output "sshd url is $url"
# Download, expand and install
Invoke-WebRequest $url -OutFile openssh.zip
if (Get-Service sshd -ErrorAction SilentlyContinue) {Stop-Service sshd}
if (Get-Service ssh-agent -ErrorAction SilentlyContinue) {Stop-Service ssh-agent}
Expand-Archive .\openssh.zip ${Env:ProgramFiles} -Force
pushd "${Env:ProgramFiles}\OpenSSH-Win64\"
.\install-sshd.ps1
popd
# Open Firewall for Port 22
if (-not (Get-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue)) {
   New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}
# Start Service and configure autostart
Start-Service -Name sshd
Set-Service -Name sshd -StartupType automatic
write-output "sshd startet and set to automatic"
# Patch sshd config to allow administrators Group public Key logon
$Quelle="${Env:ProgramData}\ssh\sshd_config"
write-output "patch the sshd config on $Quelle"
Stop-Service -Name sshd
$Inhalt = Get-Content $Quelle
#search 2 lines contains administrators and insert commment sign
$Inhalt|foreach {if ($_ -match "administrators") {$Inhalt[$_.readcount-1]=$_.Insert(0,"#")}}
set-Content $Quelle $Inhalt
Start-Service -Name sshd
