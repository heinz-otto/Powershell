<#
.SYNOPSIS
    This Script will be create a User with ShutDown priviliges
.DESCRIPTION
    The password will be asked in the dialog, it's SecureString
    see also: https://heinz-otto.blogspot.com/2018/08/hyper-v-server-verwenden.html
.EXAMPLE
    .\createShutdownUser.ps1 -User "Username" 
    .\createShutdownUser.ps1 "Username"
.NOTES
    May be, some links will be broken in the Future. (May 2019)
#>
#region Params
param(
    [Parameter(Position=0,HelpMessage="-User 'UserName'")]
    [String]$User="UserShutdown"
)
#endregion 

# check if the Module UserRights is already loaded
$cmdlet = "Grant-UserRight"
if (!( get-command -Name $cmdlet -ErrorAction SilentlyContinue)) {
   "Cmdlet $cmdlet not found - try to install."
   $url = "https://gallery.technet.microsoft.com/scriptcenter/Grant-Revoke-Query-user-26e259b0/file/198800/1/UserRights.psm1"
   $output = "UserRights.psm1"
   Invoke-WebRequest -Uri $url -OutFile $output
   Import-Module .\UserRights.psm1
}

New-LocalUser $User 
Set-LocalUser -Name $User -PasswordNeverExpires 1
Grant-UserRight -Account $User -Right SeRemoteShutdownPrivilege

# this is language independent for the Rule "File and Print ..."
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"

