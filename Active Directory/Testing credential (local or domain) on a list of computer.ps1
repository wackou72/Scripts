# Ce script permet de tester les identifiants d'ordinateurs à distance
# On test en premier la connectivité (ping)
# On test ensuite si les identifiants saisies peuvent se connecter sur le partage
#
#
# Wackou
# contact@wackou.com
# www.wackou.com
$computers = Get-Content computers.txt #lecture du fichier contenant les noms des ordinateurs en FQDN ou IP
$cred = Get-Credential #Obtention des credentials au format COMPUTER\USERNAME ou DOMAINE\USERNAME
$LogTime = Get-Date -Format "dd-MM-yyyy_HH-mm-ss" # obtenir la date dès le lancement pour LOG
$account = Read-Host "Please enter the account used" #Saisie du compte utilisé (pas possible avec get-credential)
foreach ($computer in $computers) {
    if(Test-Connection $computer -Count 1 -ErrorAction SilentlyContinue) { #Test si ordinateur en ligne, si OUI, on test
        if(New-PSDrive -Name testshare -PSProvider FileSystem -Root "\\$computer\c$" -Credential $cred -ErrorAction SilentlyContinue) { #Test de connexion sur partage administratif C$
            $status = 'Online and able to connect' # Si OUI, alors PC en ligne et connexion OK
            Remove-PSDrive testshare #Suppression du lecteur réseau temporaire
        }
        else {
            $status = 'Online but unable to connect' #Si NON, alors PC en ligne mais connexion NOK
        }
    }
    else {
        $status = 'Offline/not in DNS' # Si NON, alors PC pas en ligne
    }
    Write-Host $computer - $status # Sortie vers console
	Write-Output "$computer - $status" >> STATUS_$account-$LogTime.txt # Sortie vers fichier de log
}
