function Add-FromHistory
{
 $command = Get-History |
 Sort-Object -Property CommandLine -Unique |
 Sort-Object -Property ID -Descending |
 Select-Object -ExpandProperty CommandLine |
 Out-GridView -Title 'Wählen Sie einen Befehl!' -PassThru |
 Out-String
 $psISE.CurrentFile.Editor.InsertText($command)
}
try
{
$null = $pSISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Aus Befehlshistorie einfügen',
{Add-FromHistory},
'SHIFT+ALT+H')
} catch {}


filter grep($stichwort)
{
 # ist das Objekt ein Text?
 $noText = $_ -isnot [string]
 # falls nicht, muss das Objekt in Text umgewandelt werden
 if ($noText)
 {
 $text = $_ |
 # ... sicherstellen, dass dabei keine Informationen abgeschnitten
 # werden, indem bis zu 5000 Zeichen lange Zeilen erlaubt werden:
 Format-Table -AutoSize |
 Out-String -Width 5000 -Stream |
 # die ersten drei Textzeilen verwerfen, die die Spaltenüberschriften
 # enthalten:
 Select-Object -Skip 3
 }
 else
 {
 # einlaufende Information war bereits Text:
 $text = $_
 }

 # Objekt herausfiltern, wenn das Stichwort nicht in seiner
 # Textrepräsentation gefunden wird
 # Dabei das Platzhalterzeichen "*" am Anfang und Ende des Stichworts
 # bereits vorgeben (sucht das Stichwort "irgendwo" im Text):
 $_ | Where-Object { $text -like "*$stichwort*" }
}

function Out-ExcelReport
{
 param
 (
 $Path = "$env:TEMP\$(Get-Random).csv"
 )
 $Input | Export-Csv -Path $Path -Encoding UTF8 -NoTypeInformation -UseCulture
 Invoke-Item -Path $Path
}


function Get-Excuse
{
    $url = 'http://pages.cs.wisc.edu/~ballard/bofh/bofhserver.pl'
    $page = Invoke-WebRequest -Uri $url -UseBasicParsing

    $pattern = '(?s)<br><font size\s?=\s?"\+2">(.+)</font>'

    if ($page.content -match $pattern)
    {
      $matches[1]
    }
    


}