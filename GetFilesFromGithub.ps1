# URL
$url="https://raw.githubusercontent.com/heinz-otto/scripts/master/batch/"
# Collection of Files
$files="StartWinPE.cmd","WinPEmount.cmd","restore.cmd","FindeLW.cmd","CreatePartitions-UEFI.txt"
foreach($f in $files) {wget -O $f "$url$f"}
