$shell = New-Object –ComObject Shell.Application 
$Startup = $shell.Namespace(0x07) 
$dl = Get-ChildItem $Startup.Self.Path -Filter *.lnk 
#$dl += Get-ChildItem $Startup.Self.Path -Filter *.url 
#$dl += Get-ChildItem $Startup.Self.Path -Filter *.website 

$dl | foreach { 
    if ($_.DirectoryName –eq $Startup.Self.Path) { 
         $fi = $Startup.ParseName($_.Name) 
    } 
    if ($fi.IsLink) { 
       $sc = $fi.GetLink 
       #$sc.Path = $sc.Path.Replace("ALTEU") 
       #$sc.Save() 
       $sc
    } 
}