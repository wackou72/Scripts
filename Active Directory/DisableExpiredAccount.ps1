<#
wackou 06/09/2018 ce script permet de chercher les comptes expirés puis de désactiver ces memes comptes et déplacer dans OU _Disable People
#>
# VARIABLES
$OU = 'OU=_Disable People,DC=mydomain,DC=com'
$Date = Get-Date -format "dd/MM/yyyy"
$From = "no-reply@mydomain.com"
$To = "IT@mydomain.com"
$SMTPServer = "mail.mydomain.com"
#
$ExpiredAccountsNotDisabled = Search-ADAccount -AccountExpired | Where-Object { $_.Enabled -eq $true }
#
ForEach($User in $ExpiredAccountsNotDisabled) {
	# Mise en place de la description et désactivation du compte
	Set-ADUser -Identity $User.SamAccountName -Description "Script $Date compte desactive" -Enabled $false
	# Déplacement du compte dans OU
	Get-ADUser -identity $User.SamAccountName | Move-ADobject -targetpath $OU
	# Objet du mail
	$Subject = "Account Disable Notification for " + $User.Name
	# Corps du mail
	$Body = 
	"
	Bonjour,<br/>
	Le compte $($User.Name) a &eacutet&eacute d&eacutesactiv&eacute et d&eacuteplac&eacute automatiquement.<br/>
	Le compte a expir&eacute le $($User.AccountExpirationDate) (Format de date US, MM/DD/YYYY).<br/>
	Pensez &agrave d&eacutesactiver le compte Exchange Office 365 et d&eacutesassocier la licence Office 365<br/>
	Bonne journ&eacutee.
	"
	# Envoi du mail
	Send-MailMessage -To $To -From $From -Subject $Subject -SmtpServer $SMTPServer -Body $Body -BodyAsHtml
}
