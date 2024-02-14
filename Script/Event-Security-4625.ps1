echo ""
echo "### Event - Security - ID 4625"
$Events = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -ErrorAction Ignore
if(! $?){ echo "Not Exist" }
foreach($Event in $Events){
	# Convert the event to XML
	$XMLs = [xml]$Event.ToXml()
	foreach($XML in $XMLs){
		$Log = New-Object psobject -Property @{
			Date = $Event.TimeCreated
			User = $XML.Event.EventData.Data[5].'#text'
			IP = $XML.Event.EventData.Data[19].'#text'
		}
		$Log
	}
}

Start-Sleep -Seconds 1
echo ""
cmd /c 'pause'
