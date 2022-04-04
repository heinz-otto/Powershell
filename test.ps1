# powershell -nop -c (Invoke-WebRequest -Uri https://raw.githubusercontent.com/heinz-otto/Powershell/master/test.ps1).content|powershell -
#Get-ChildItem 'c:\'
$u='https://raw.githubusercontent.com/heinz-otto/Powershell/master/ChangeVariableInsideScript.ps1'
$f=[System.IO.Path]::GetTempFileName()+'.ps1'
Invoke-WebRequest -Uri $u -outfile $f
$f
