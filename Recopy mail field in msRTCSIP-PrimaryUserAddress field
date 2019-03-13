# Copier le champ mail dans msRTCSIP-PrimaryUserAddress d'un utilisateur Active Directory
#
#
# Wackou
# contact@wackou.com
# www.wackou.com
#VARIABLES
$global:SITE = $NULL #initilisation variable site
$OU = "LDAP://DC=domaine,DC=local" #OU par defaut
$FILTER = "(&(mail=*)(!(msRTCSIP-PrimaryUserAddress=sip:*@*)))" #filtre sur le champ mail, celui doit etre remplie et le champs SIP vide
$global:SEARCHER = $NULL #initilisation variable recherche adsi
$global:LogTime = Get-Date -Format "dd-MM-yyyy_HH-mm-ss" # obtenir la date dès le lancement pour LOG
#FONCTIONS
function recopy {
	$SEARCHER.FindAll() | Foreach {
		$user = $_.GetDirectoryEntry()
			$user."msRTCSIP-PrimaryUserAddress"="sip:"+$user."mail" #recopie du champs mail dans SIP
			$user.SetInfo() #on enregistre les informations
			$user.mail >> C:\script\CopyMail2SIP_$LogTime.txt #log pour connaitre les comptes modifies
		}
		
	}
cls
$SITE = Read-Host "Saisir le nom du site (1, 2, etc ...)" #saisie du site
If ($SITE -eq '') { #verification si l'utilisateur a saisie qqch
		write-host "Merci de saisir un site !"$OU -foregroundcolor white -backgroundcolor red
		break
}
$OU = "LDAP://OU=People,OU=$SITE,DC=domaine,DC=local" #construction du chemin LDAP
If ([adsi]::Exists($OU)) { #verification si le chemin LDAP est valide
		write-host "Site selectionne :"$OU
		$SEARCHER = New-Object adsisearcher([adsi]$OU , $FILTER) #construction de la recherche adsi
		recopy #lancement de la fonction
}
Else {
		Write-host "Ce site n'existe pas !"$OU -foregroundcolor white -backgroundcolor red
}
