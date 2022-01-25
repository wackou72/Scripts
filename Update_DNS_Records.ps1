$file = Read-Host "Please type a file name"
$csv = Import-Csv "$file"
$zone = "mydomain.com"
$server = "192.168.1.254"
ForEach($line in $csv){
	$oldobj = Get-DnsServerResourceRecord -name $line.Name -ZoneName $zone -RRType A -ComputerName $server
	$newobj = $oldobj.Clone()
	$newobj.RecordData.ipv4address = [System.Net.IPAddress]::parse($line.IP)
	Set-DnsServerResourceRecord -newinputobject $newobj -oldinputobject $oldobj -zonename $zone -passthru -computername $server
}