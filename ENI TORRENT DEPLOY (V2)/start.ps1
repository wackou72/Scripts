$OU="OU=Salles,DC=domaine,DC=local"#OU où se trouvent les salles/PC
dsquery OU "$OU"  -o rdn -name 'Salle *' |%{$_ -replace '"', ""} > TEMP\salles.txt
Get-ChildItem -path TORRENT -filter *.torrent -name > TEMP\torrent.txt
