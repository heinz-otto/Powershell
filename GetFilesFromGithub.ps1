# URL
$url="https://raw.githubusercontent.com/heinz-otto/scripts/master/batch/"
# Collection of Files
$files="StartWinPE.cmd","WinPEmount.cmd","restore.cmd","capture.cmd","FindeLW.cmd","CreatePartitions-UEFI.txt"
# Destination Path if other than actual path
$dest=""
foreach($f in $files) {wget -O "$dest$f" "$url$f"}
