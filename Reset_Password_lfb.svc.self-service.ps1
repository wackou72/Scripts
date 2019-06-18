<#
wackou 18/12/2018, ce script permet de changer le mot d'un compte AD
#>
# VARIABLES
$Alphabet = "a b c d e f g h i j k l m n o p q r s t u v w x y z @ ! ? # $ % 0 1 2 3 4 5 6 7 8 9"
$TabAlpha = $Alphabet.Split(" ")
$Password = ""
$Max = $TabAlpha.count
$NbreCaracteres = 8
$From = "no-reply@mydomain.com"
$To = "me@mydomain.com"
$CC ="IT@mydomain.com"
$SMTPServer = "mail.mydomain.com"
$Subject = "Password reset for myaccount"
For ($nbcar = 1 ; $NbCar -le $NbreCaracteres ; $nbCar++)
	{
	if ((Get-Random -min 0 -max 100) -lt 50) {$Password += $TabAlpha[$(Get-Random -min 1 -max $Max)].tolower()}
	else {$Password += $($TabAlpha[$(Get-Random -min 1 -max $Max)]).toupper()}
	}
# Corps du mail
$Body = 
	"
	Bonjour,<br/>
	le mot de passe du compte <i>myaccount</i> a &eacutet&eacute r&eacuteinitialis&eacute.<br/.>
	Le nouveau mot de passe est le suivant : <b>$Password</b><br/>
	Celui-ci sera r&eacuteinitialis&eacute dans 3 mois.<br/>
	Bonne journ&eacutee.
	"
Set-ADAccountPassword –Identity "CN=myaccount,OU=IT,DC=mydomain,DC=com" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
Send-MailMessage -To $To -Cc $CC -From $From -Subject $Subject -SmtpServer $SMTPServer -Body $Body -BodyAsHtml