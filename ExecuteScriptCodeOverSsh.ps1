<#
.SYNOPSIS
    execute a WOL Oneliner over ssh on linux host
.DESCRIPTION
    show the usage of params, Call (&) Operator and combination of double and single quoted here string
.EXAMPLE
    scriptname.ps1 -ziel 'user@host' -mac 'aa:bb:cc:11:22:33'
.NOTES
    This Script is more a study: How to execute some code over ssh remotely
#>
param(
  [Parameter(Mandatory=$true,HelpMessage="give dest: username@hostname")] $dest,
  [Parameter(Mandatory=$true,HelpMessage="give mac: aa:bb:cc:11:22:33")] $mac,
  $bc='255.255.255.255',$port='9'
)
# get the full path of the executable
$exe=(Get-Command ssh).path
# first script part with double quoted here string: to replace the variable with values
# last empty line ist for linebreak to the second part
$script=@"
MAC=$mac
Broadcast=$bc
PortNumber=$port

"@
# second script part with single quoted here string: to leave all untouched
$script+=@'
echo -e $(echo $(printf 'f%.0s' {1..12}; printf "$(echo $MAC | sed 's/://g')%.0s" {1..16}) | sed -e 's/../\\x&/g') | nc -w1 -u -b $Broadcast $PortNumber
'@
# it's important to change the linebreaks from windows to linux style!
# use separate strings for exe, first argument, second argument
& $exe $dest $script.replace("`r`n","`n")
