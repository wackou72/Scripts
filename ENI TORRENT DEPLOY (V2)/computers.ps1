param($salles)
$OU="OU=Salles,DC=domaine,DC=local"#OU où se trouvent les salles/PC
dsquery computer "OU=$salles,$OU" -o rdn |% {$_ -replace '"', ""} > TEMP\computers.txt
