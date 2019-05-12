# need WMF 5.1, try to install on Windows Server 2012
if ($PSVersionTable.PSVersion.tostring(2) -lt 5.1){
    write-output "No WMF 5.1, search Windows Server 2012"
    # Get the OS Version
    $w32caption=(Get-WmiObject -class Win32_OperatingSystem).Caption
    if ($w32caption -match "Windows Server 2012 R2") {$Spattern="W2K12R2-"}
    elseif ($w32caption -match "Windows Server 2012") {$Spattern="W2K12-"}
    else {Write-Output "Setup WMF5 manually";exit}
    write-output "Windows Server 2012 detected $Spattern"
    <#
        # The following Code is original from https://gist.github.com/mgreenegit/b80ddd089677f92f56f5
        # Use shortcode to find latest TechNet download site
        $confirmationPage = 'http://www.microsoft.com/en-us/download/' +  $((invoke-webrequest 'http://aka.ms/wmf5latest' -UseBasicParsing).links | ? Class -eq 'mscom-link download-button dl' | % href)
        # Parse confirmation page and look for URL to file
        $directURL = (invoke-webrequest $confirmationPage -UseBasicParsing).Links | ? Class -eq 'mscom-link' | ? href -match $Spattern | % href | select -first 1
        write-output "url for WMF 5.1 is $directURL"
        # Download file to local
        $download = invoke-webrequest $directURL -OutFile $env:Temp\wmf5latest.msu
    #>
    # Because the code above don't working on Windows Server 2012, I will using the direkt link instead
    # May be this linkes will be broken in the future
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
    write-output "WMF 5 installed, reboot is needed! Reboot now and run Script simply again"
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
Expand-Archive .\openssh.zip ${Env:ProgramFiles}
cd "${Env:ProgramFiles}\OpenSSH-Win64\"
.\install-sshd.ps1
# Open Firewall for Port 22
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
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
