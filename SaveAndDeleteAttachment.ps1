<#
.SYNOPSIS
    Extract attachments from Outlook Folder
.DESCRIPTION
    Outlook Mapi have to installed and configured
    from all readed messages the attachments will be extracted, the message Date is keeped in the saved file
    the Path for attachments may be created
    default is: Mailbox & Folder by pickup or if mbName is given use 'Posteingang', older 15 days, no change

.EXAMPLE
    SaveAndDeleteAttachment
    SaveAndDeleteAttachment -mbName 'name@domain.de'
    SaveAndDeleteAttachment -mbName 'name@domain.de' -mbfolder 'Gesendete Objekte' -days '-15' -change $true
    SaveAndDeleteAttachment -change $true
.NOTES
    Some notes
#>

#region Params
  param
  (
    [Parameter(Mandatory=$false)]
    $mbName = '',$mbFolder = 'Posteingang',$days = -15,$change = $false
  )
#endregion 

$path = ".\attachments"                            # kann relativ sein
#$rnd = Get-Random -Maximum 999999 -Minimum 123456  # Erzeuge 6 stellige Zufallszahl
#$message.ReceivedTime.ToString("yyyyMMddhhmm")     # Timestamp erzeugen
$Hinweis = "Einfach den kompletten Pfad kopieren und im Dateiexplorer wieder einfügen"

if (-not (Test-Path $path)) {mkdir $path}
$fullpath = (get-item $path).FullName
$outlook = new-object -com Outlook.Application
$mapi = $outlook.GetNameSpace("MAPI")

# Mailfolder auswählen über default (ungeeignet bei mehreren Mailboxen im Profil)
# $session = $outlook.Session
# $session.Logon()
# $folder = $outlook.session.GetDefaultFolder(5)    # 3 olFolderDeletedItems, 4 olFolderOutbox, 5 olFolderSentMail, 6 olFolderInbox

# Mailfolder im Auswahlfenster wählen oder direkt angegeben
if ($mbname -eq '') {$folder = $mapi.pickfolder()} else {$folder = $mapi.Folders.Item($mbname).Folders.Item($mbfolder)}

# Statistische Werte sammeln Zähler initialisieren
$size = 0                           # saved attachments size
$ItemCount   = $folder.items.Count  # all messages 
$unreadCount = 0                    # unread messages (%{$folder.Items | where {$_.UnRead}}).Count
$readCount   = 0                    # read messages (%{$folder.Items | where {$_.UnRead -eq $false}}).Count
$amsize=0                           # all message size
$rmsize=0                           # read message size
$umsize=0                           # unread message size

# Hauptprogrammschleife über alle Nachrichten des Ordners
# Nur gelesene Nachrichten bearbeiten
# Alle Attachments speichern, Zeile im Body anfügen und löschen

foreach ($message in $folder.items) {
  #if ($message.Subject.Contains("Spambericht") ) {
  #      write-output "$($message.ReceivedTime) $($message.Subject)"
  #      $amsize += $message.size
  #}
  $strDelFiles=''
  $amsize += $message.size
  # 3 Tests der Nachricht: -ungelesen, -Alter, Anhang vorhanden
  if ($message.UnRead -eq $false -and $message.ReceivedTime -lt (Get-Date).AddDays($days) -and $message.Attachments.count -gt 0) {
     $readCount++
     $rmsize += $message.size
     # Das Object wird bei jedem Durchlauf verändert und der Index beginnt bei 1:
     # - for Schleife die herunter bis 1 zählt 
     # https://www.slipstick.com/developer/code-samples/save-and-delete-attachments/
     for ($i=$message.Attachments.count; $i -ge 1; $i--){
         $attach = $message.Attachments[$i]
         $size += $attach.Size
         $AFN = $attach.filename
         $MRT = $message.ReceivedTime
         $extension = $AFN.split('\.')[-1]
         $fullfile = (Join-Path $fullpath $AFN.insert($AFN.IndexOf(".$extension"),"_$($MRT.ToString('yyyyMMddhhmm'))"))
 
         # Bei Bedarf nur Analyse
         # Anhang als Datei speichern und Änderungsdatum setzen, Anhang löschen
         If ($change) {
            $attach.SaveAsFile($fullfile)
            $(Get-Item $fullfile).lastwritetime=$(Get-Date $MRT)
            $attach.delete()
         }
         # Namen der Anhänge aufsummieren
         $strDelFiles += "`n$fullfile"
    }
    write-verbose "$($MRT.ToString("dd.MM.yyyy hh:mm")) $($message.Subject) $strDelFiles" 
    If ($change) {
       # Nachricht Body ergänzen und Änderung speichern
       if ($message.BodyFormat -eq 2){
           $message.HTMLBody += "<p>$Hinweis</p>"
           $message.HTMLBody += "<p>Die Dateien wurden auf dem Computer $env:computername gespeichert: " + $strDelFiles.Replace("`n","<br>") + "</p>"
       } elseif ($message.BodyFormat -eq 1) {
           $message.Body += "`n$Hinweis"
           $message.Body += "`nDie Dateien wurden auf dem Computer $env:computername gespeichert: $strDelFiles"
       }
       $message.Save()
    }
  } else {$unreadCount++;$umsize += $message.size}
}

#Statistik ausgeben

$statistic = "Status für die Mailbox $($folder.FolderPath) :"
$statistic += "`n" + $("$ItemCount Nachrichten mit {0:N2} MB vorhanden" -f $($amsize/1MB) )
$statistic += "`n" + $("$readCount Nachrichten gelesen oder älter als $days Tage mit {0:N2} MB vorhanden" -f $($rmsize/1MB) )
$statistic += "`n" + $("$unreadCount Nachrichten ohne Anhang oder ungelesen oder neuer als $days Tage mit {0:N2} MB vorhanden" -f $($umsize/1MB) )
If ($change) {$statistic += "`n" + $("{0:N2} MB Attachments wurden entfernt und gespeichert" -f $($size/1MB))}
else {$statistic += "`n" + $("{0:N2} MB Attachments wären entfernt und gespeichert worden" -f $($size/1MB))}
Write-verbose $statistic