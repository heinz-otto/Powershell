#Get-ChildItem 'c:\'
$u='https://raw.githubusercontent.com/heinz-otto/Powershell/master/ChangeVariableInsideScript.ps1'
$f=[System.IO.Path]::GetTempFileName()+'.ps1'
Invoke-WebRequest -Uri $u -outfile $f
$f