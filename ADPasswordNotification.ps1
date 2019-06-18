##############Variables#################
$verbose = $false
$notificationstartday = 14
$sendermailaddress = "no-reply@mydomain.com"
$SMTPserver = "mail.mydomain.com"
$DN = "DC=domain,DC=com"
########################################

##############Function##################
function PreparePasswordPolicyMail ($ComplexityEnabled,$MaxPasswordAge,$MinPasswordAge,$MinPasswordLength,$PasswordHistoryCount)
{
    $verbosemailBody = "Below is a summary of the applied Password Policy settings:`r`n`r`n"
    $verbosemailBody += "Complexity Enabled = " + $ComplexityEnabled + "`r`n`r`n"
    $verbosemailBody += "Maximum Password Age = " + $MaxPasswordAge + "`r`n`r`n"
    $verbosemailBody += "Minimum Password Age = " + $MinPasswordAge + "`r`n`r`n"
    $verbosemailBody += "Minimum Password Length = " + $MinPasswordLength + "`r`n`r`n"
    $verbosemailBody += "Remembered Password History = " + $PasswordHistoryCount + "`r`n`r`n"
    return $verbosemailBody
}
           
function SendMail ($SMTPserver,$sendermailaddress,$usermailaddress,$mailBody)            
{
    $smtpServer = $SMTPserver
    $msg = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $msg.IsBodyHTML = $true
    $msg.From = $sendermailaddress
    $msg.To.Add($usermailaddress)
    $msg.Subject = "Your password is about to expire"
    $msg.Body = $mailBody
    $smtp.Send($msg) 
}
########################################

##############Main######################
$domainPolicy = Get-ADDefaultDomainPasswordPolicy
$passwordexpirydefaultdomainpolicy = $domainPolicy.MaxPasswordAge.Days -ne 0

if($passwordexpirydefaultdomainpolicy)
{
    $defaultdomainpolicyMaxPasswordAge = $domainPolicy.MaxPasswordAge.Days
    if($verbose)
    {
        $defaultdomainpolicyverbosemailBody = PreparePasswordPolicyMail $PSOpolicy.ComplexityEnabled $PSOpolicy.MaxPasswordAge.Days $PSOpolicy.MinPasswordAge.Days $PSOpolicy.MinPasswordLength $PSOpolicy.PasswordHistoryCount
    }
}
            
foreach ($user in (Get-ADUser -SearchBase $DN -Filter {passwordneverexpires -eq "FALSE"} -properties mail))            
{            
    $samaccountname = $user.samaccountname            
    $PSO= Get-ADUserResultantPasswordPolicy -Identity $samaccountname            
    if ($PSO -ne $null)            
    {                         
        $PSOpolicy = Get-ADUserResultantPasswordPolicy -Identity $samaccountname            
        $PSOMaxPasswordAge = $PSOpolicy.MaxPasswordAge.days            
        $pwdlastset = [datetime]::FromFileTime((Get-ADUser -LDAPFilter "(&(samaccountname=$samaccountname))" -properties pwdLastSet).pwdLastSet)            
        $expirydate = ($pwdlastset).AddDays($PSOMaxPasswordAge)            
        $delta = ($expirydate - (Get-Date)).Days            
        $comparionresults = (($expirydate - (Get-Date)).Days -le $notificationstartday) -AND ($delta -ge 1)            
        if ($comparionresults)            
        {            
            $mailBody = "<p>Cher " + $user.GivenName + " " + $user.Surname + ",</p>"            
            $mailBody += 
            "<p> Votre mot de passe expirera dans " + $delta +
            " jours.<br/>Merci d'effectuer la modification du mot de passe.<br/>
              Au del&agrave de ce d&eacutelai, vous ne pourrez plus vous connecter</p>
              <p>comment modifier votre mot de passe Windows</p>
              <p><ul>
              <li>Vous devez etre connect&eacute sur le r&eacuteseau.</li>
              <li>Appuyez sur Ctrl+Alt+Suppr, puis cliquez sur Modifier un mot de passe.</li>
              <li>Tapez l’ancien mot de passe, puis le nouveau mot de passe à deux reprises pour le confirmer.</li>
              <li>Appuyez sur Entrée.</li></ul></p>
			  <p>Le mot de passe ne doit pas contenir le nom de compte de l’utilisateur ou des parties du nom complet de l’utilisateur comptant plus de deux caractères successifs
			  <br />Comporter au moins huit caractères
			  <br />Contenir des caractères provenant des quatre catégories suivantes :</p>
			  <ul><li>Caractères majuscules (A à Z)</li>
			  <li>Caractères minuscules (a à z)</li>
			  <li>Chiffres en base 10 (0 à 9)</li>
			  <li>Caractères non alphabétiques (par exemple, !, $, #, %)</li></ul>
			  "
             if ($verbose)            
                {            
                    $mailBody += $defaultdomainpolicyverbosemailBody            
                }
             #$mailBody += "<p>Le Service Informatique</p>"
             $mailBody +=
             "<p>-------------------------------------------------------------------------------------------------------------</p>
             <p>Dear " + $user.GivenName + " " + $user.Surname +  ",</p>
             <p>Your password will expire after " + $delta + " days. <br />
                You will need to change your password to keep using your account.</p>
                <p>How to change your Windows password</p>
                <p><ul>
				<li>You should be connected to the network.</li>
				<li>Press Ctrl+Alt+Delete, and then click Change a password.</li>
                <li>Type your old password followed by a new password as indicated, and then type the new password again to confirm it.</li>
                <li>Press Enter.</li></ul></p>
				<p>Your password should not contain the user's account name or parts of the user's full name that exceed two consecutive characters
				<br />Be at least eight characters in length
				<br />Contain characters from following four categories :</p>
				<ul><li>Uppercase characters (A through Z)</li>
				<li>Lowercase characters (a through z)</li>
				<li>Base 10 digits (0 through 9)</li>
				<li>Non-alphabetic characters (for example, !, $, #, %)</li></ul>
                "
            if ($verbose)            
            {            
                $mailBody += PreparePasswordPolicyMail $PSOpolicy.ComplexityEnabled $PSOpolicy.MaxPasswordAge.Days $PSOpolicy.MinPasswordAge.Days $PSOpolicy.MinPasswordLength $PSOpolicy.PasswordHistoryCount            
            }            
            $mailBody += "
            <p>Merci de votre compr&eacutehension/Thanks for your kind understanding<br />,
            Le Service Informatique</p>"
            $usermailaddress = $user.mail
            SendMail $SMTPserver $sendermailaddress $usermailaddress $mailBody
        }            
    }            
    else            
    {            
        if($passwordexpirydefaultdomainpolicy)            
        {            
            $pwdlastset = [datetime]::FromFileTime((Get-ADUser -LDAPFilter "(&(samaccountname=$samaccountname))" -properties pwdLastSet).pwdLastSet)            
            $expirydate = ($pwdlastset).AddDays($defaultdomainpolicyMaxPasswordAge)            
            $delta = ($expirydate - (Get-Date)).Days            
            $comparionresults = (($expirydate - (Get-Date)).Days -le $notificationstartday) -AND ($delta -ge 1)            
            if ($comparionresults)            
            {            
                #$mailBody = "Dear " + $user.GivenName + ",`r`n`r`n"            
                $delta = ($expirydate - (Get-Date)).Days            
                # $mailBody += "Your password will expire after " + $delta + " days. You will need to change your password to keep using it.`r`n`r`n"
                $mailBody = "<p>Cher " + $user.GivenName + " " + $user.Surname + ",</p>"            
                $mailBody += 
                "<p> Votre mot de passe expirera dans " + $delta +
                " jours.<br />Merci d'&eacuteffectuer la modification du mot de passe.
                <br />Au del&agrave de ce d&eacutelai, vous ne pourrez plus vous connecter.</p>
                <p>Comment modifier votre mot de passe Windows</p>
                <p>
				<li>Vous devez etre connect&eacute sur le r&eacuteseau</li>
				<li>Appuyez sur Ctrl+Alt+Suppr, puis cliquez sur Modifier un mot de passe.</li>
                <li>Tapez l’ancien mot de passe, puis le nouveau mot de passe à deux reprises pour le confirmer.</li>
                <li>Appuyez sur Entrée.</li></p>
				<p>Le mot de passe ne doit pas contenir le nom de compte de l’utilisateur ou des parties du nom complet de l’utilisateur comptant plus de deux caractères successifs
				<br />Comporter au moins huit caractères
				<br />Contenir des caractères provenant des quatre catégories suivantes :</p>
				<ul><li>Caractères majuscules (A à Z)</li>
				<li>Caractères minuscules (a à z)</li>
				<li>Chiffres en base 10 (0 à 9)</li>
				<li>Caractères non alphabétiques (par exemple, !, $, #, %)</li></ul>
				"
                if ($verbose)            
                {            
                    $mailBody += $defaultdomainpolicyverbosemailBody            
                }
                #$mailBody += "<p>Le Service Informatique</p>"
                $mailBody +=
                "<p>-------------------------------------------------------------------------------------------------------------</p>
                <p>Dear " + $user.GivenName + " " + $user.Surname + ",</p>
                <p>Your password will expire after " + $delta + " days. <br>
                You will need to change your password to keep using your account.</p>
                <p>How to change your Windows password</p>
                <p><ul>
				<li>You should be connected to the network.</li>
				<li>Press Ctrl+Alt+Delete, and then click Change a password.</li>
                <li>Type your old password followed by a new password as indicated, and then type the new password again to confirm it.</li>
                <li>Press Enter.</li></ul></p>
				<p>Your password should not contain the user's account name or parts of the user's full name that exceed two consecutive characters
				<br />Be at least eight characters in length
				<br />Contain characters from following four categories :</p>
				<ul><li>Uppercase characters (A through Z)</li>
				<li>Lowercase characters (a through z)</li>
				<li>Base 10 digits (0 through 9)</li>
				<li>Non-alphabetic characters (for example, !, $, #, %)</li></ul>
                "
                if ($verbose)            
                {            
                    $mailBody += $defaultdomainpolicyverbosemailBody            
                }
                $mailBody += "
                <p>Merci de votre compr&eacutehension/Thanks for your understanding</p>
                <p>Le Service Informatique/IT Services</p>"            
                $usermailaddress = $user.mail            
                SendMail $SMTPserver $sendermailaddress $usermailaddress $mailBody      
            }            
            
        }            
    }            
}