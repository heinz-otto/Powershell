<#
.SYNOPSIS
    ssh-copy-id for Powershell
.DESCRIPTION
    copying the public key from Windows to linux or Windows hosts.
    Could be support different destion path like OpenWrt.
.EXAMPLE
    ssh-copy-id user@host
    ssh-copy-id user@host -path /etc/dropbear   #e.g. for OpenWrt
    ssh-copy-id user@host win
    ssh-copy-id -i .ssh\id_rsa.pub user@host
    ssh-copy-id -i .ssh\id_rsa.pub user@host win
.NOTES
    Some notes
#>

#region Params
  param
  (
    [Parameter(Mandatory=$true)]
    $ziel,
    [Parameter(Mandatory=$false)]
    $os = '',$i = "$env:userprofile\.ssh\id_rsa.pub",$path='.ssh'
  )
#endregion 
write-verbose "Destination: $ziel`r`nPublicKeyLocation: $i`r`nDestinationOS: $os`r`nDestinationPath: $path"

$pkey = $(type $i) 

if ($os -eq '' -or $os -ne 'win') {
$cmd=@"
if ! grep -q `"`"$pkey`"`" $path/authorized_keys
then
  mkdir -p $path
  echo $pkey >> $path/authorized_keys
else
  echo 'Key always exist'
fi
"@
} else {
  $cmd="findstr /c:`"`"$pkey`"`" $path\authorized_keys||mkdir $path ||echo $pkey >>$path\authorized_keys"
}

write-verbose "complete cmd: $cmd"
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
  ssh $ziel $cmd.replace("`r`n","`n")
}
else {
  ssh $ziel $cmd.replace("`r`n","`n") 2>&1>$null
}
