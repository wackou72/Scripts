$AccountLockOutEvent = Get-EventLog -LogName "Security" -InstanceID 4740 -Newest 1
$LockedAccount = $($AccountLockOutEvent.ReplacementStrings[0])
$AccountLockOutEventTime = $AccountLockOutEvent.TimeGenerated
$AccountLockOutEventMessage = $AccountLockOutEvent.Message

$messageParameters = @{ 

    Subject = "Account Locked Out: $LockedAccount" 
    Body = "Account $LockedAccount was locked out on $AccountLockOutEventTime.`n`nEvent Details:`n`n$AccountLockOutEventMessage"
    From = "lockout@mydomain.com" 
    To = "it@mydomain.com" 
    SmtpServer = "mail.mydomain.com"

}

Send-MailMessage @messageParameters
