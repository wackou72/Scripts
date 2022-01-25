<#
wackou 11/06/2019, ce script permet de mettre à jour les champs Office / Company / City / Country des objets utilisateurs se trouvant dans les OU People des différents sites
#>
# MY SITE
Get-ADUser -Filter * -SearchBase "OU=IT,DC=domain,DC=com" | Foreach {Set-ADUser $_ -Office "IT HQ" -Company "MY IT COMPANY" -City "TOKYO" -Country "JP"}
