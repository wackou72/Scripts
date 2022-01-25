<#
wackou 05/09/2018, script permettant de recuperer les comptes qui vont expirer dans 14J
envoi le mail à l'utilisateur ainsi qu'au groupe de distribution IT@mydomain.com
script inspiré d'ici : https://www.reddit.com/r/PowerShell/comments/3f1q6d/assistance_with_script_to_email_manager_of/
#>
# variables
$From = "no-reply@mydomain.com"
$CC = "IT@mydomain.com"
#Pour debug
$SMTPServer = "mail.mydomain.com"

#On recupere la date et on rajoute les 14 jours
$startDate = Get-Date
$endDate = $startDate.AddDays(14)

#On recupere tous les comtpes de AD en fonction de la date de fin+14J
$Users = Get-ADUser -Filter {AccountExpirationDate -gt $startDate -and AccountExpirationDate -lt $endDate} -Properties AccountExpirationDate, Mail

#Debut de l'envoi de mail
Foreach($User in $Users)
{
	$To = $User.Mail
	#Pour debug
	$Subject = "Account Expiration Notification for " + $User.Name
	$Body =
	"
	<p>Bonjour,<br/>
	Cette notification vous informe que le compte pour $($User.Name) expirera le $($User.AccountExpirationDate) (Format de date US, MM/DD/YYYY).<br/>
	Si votre compte doit etre prolong&eacute, veuillez contacter votre responsable.</p>
	<p>-------------------------------------------------------------------------------------------------------------</p>
	<p>Hello,<br/>
	This notification is to inform you that the account for $($User.Name) will expire on $($User.AccountExpirationDate) (US Date format, MM/DD/YYYY). <br/>
	If your account need to be extended, please contact your manager.</p>
	<br/>
	<br/>
	Merci de votre compr&eacutehension/Thanks for your understanding<br/>
	Le Service Informatique/IT Services<br/>
	"
	Send-MailMessage -To $To -Cc $CC -From $From -Subject $Subject -SmtpServer $SMTPServer -Body $Body -BodyAsHtml
}
