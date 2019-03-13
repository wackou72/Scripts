# Permet de deployer des fichiers sur des postes en utilisant le protocole bittorrent
# Pour cela, on liste chaque salles présentes dans une OU, l'utilisateur sélectionne la salle
# On récupère la liste des PC de la salle choisie
# On recupère la liste des .torrent disponibles (cours), l'utilisateur choisie le cours
# On test enfin la connection au PC, si OK on kill le processus utorrent.exe, on créé les repertoires necessaire 
# puis copie du .torrrent et enfin on lance utorrent
# Si test NOK, un message d'erreur s'affiche et on passe au PC suivant
# Le script permet de générer des logs pour garder un historique
#
# Wackou
# contact@wackou.com
# www.wackou.com

#VARIABLES
$window = (Get-Host).UI.RawUI
$window.WindowTitle = "ENI TORRENT DEPLOY"
import-module ServerManager #Pour rendre compatible Windows Server 2008 avec la commande Get-WindowsFeature
$DATA="C:\DATA" # Dossier de destination, les fichiers seront téléchargés ici
$TORRENT_C="C:\torrent" # Dossier contenant les .torrent en destination (client)
$TORRENT_S="TORRENT" #Dossier contenant les .torrents (serveur)
$TEMP="TEMP" #Dossier temporaire pour recevoir les fichiers et logs
$BIN="BIN" #Dossier contenant les binaires
$counter_cours=-1 #Compteur pour le nom du .torrent
$counter_salles=-1 #Compteur pour le nom de la salle
$LogTime = Get-Date -Format "dd-MM-yyyy_HH-mm-ss" # obtenir la date dès le lancement pour LOG
$log = 1 # 1 ou 0 pour gestion des logs ou non
$OU="OU=Salles,DC=domaine,DC=local"#OU où se trouvent les salles/PC
$RSAT = Get-WindowsFeature RSAT-ADDS-Tools #variable pour récupèrer le statut de RSAT-ADDS-Tools

#FONCTIONS
function check {#Check de l'environnement, des dossiers et RSAT-ADDS-Tools
If (Test-Path $TEMP){ #check si dossier $TEMP présent
	#OK
	}Else{
		write-host "Le dossier $TEMP n'existe pas !" -foregroundcolor white -backgroundcolor red
		Read-Host "Press Enter to continue..." #Hack pause si version powershell < 3
		exit
	}
#Powershell execution policy
#set-executionpolicy -scope process -force remotesigned
#set-executionpolicy -scope localmachine -force remotesigned
If ($PSVersionTable.PSVersion.Major -ge 3){ #check la version de Powershell (minimum 3)
	#OK
	}Else{
		write-host "La version minimum de Powershell requise est 3 !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> La version minimum de Powershell requise est 3 !" >> $TEMP\LOG_$LogTime.txt
			}
		Read-Host "Press Enter to continue..." #Hack pause si version powershell < 3
		exit
	}
If (Test-Path $TORRENT_S){ #check si dossier $TORRENT_S présent
	#OK
	}Else{
		write-host "Le dossier $TORRENT_S n'existe pas !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> Le dossier $TORRENT_S n'existe pas !" >> $TEMP\LOG_$LogTime.txt
			}
		pause
		exit
	}
If (Test-Path $BIN){ #check si dossier $BIN présent
	#OK
	}Else{
		write-host "Le dossier $BIN n'existe pas !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> Le dossier $BIN n'existe pas !" >> $TEMP\LOG_$LogTime.txt
			}
		pause
		exit
	}
If (Test-Path $BIN\psexec.exe){ #check si fichier $BIN\psexec.exe présent
	#OK
	}Else{
		write-host "Le fichier psexec.exe n'existe pas !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> Le fichier psexec.exe n'existe pas !" >> $TEMP\LOG_$LogTime.txt
			}
		pause
		exit
	}
If (Test-Path $BIN\utorrent.exe){ #check si fichier $BIN\utorrent.exe présent
	#OK
	}Else{
		write-host "Le fichier utorrent.exe n'existe pas !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> Le fichier utorrent.exe n'existe pas !" >> $TEMP\LOG_$LogTime.txt
			}
		pause
		exit
	}
If ($RSAT.Installed -eq "True"){#check si RSAT-ADDS-Tools installé, sinon on installe
	#OK
	}Else{
		Write-Host "RSAT-ADDS-Tools non installe !" -foregroundcolor white -backgroundcolor red
			if ($log) {
			time
			write-output "$time --> RSAT-ADDS-Tools non installe !" >> $TEMP\LOG_$LogTime.txt
			}
		Install-WindowsFeature RSAT-ADDS-Tools | Out-Null
	}
}
function time{ #Obtenir l'heure lors de l'appel de la fonction (utilise pour les logs)
	$global:time=Get-Date -Format "HH:mm:ss"
}
function clean { #ne pas afficher les messages d'informations
	Select-Object -Property * -ExcludeProperty *
}
function header { #ENI TORRENT DEPLOY ASCII ART
cls
write-host "              
               ______ _   _ _____   _______ ____  _____  _____  ______ _   _ _______ 
              |  ____| \ | |_   _| |__   __/ __ \|  __ \|  __ \|  ____| \ | |__   __|
              | |__  |  \| | | |      | | | |  | | |__) | |__) | |__  |  \| |  | |   
              |  __| | .   | | |      | | | |  | |  _  /|  _  /|  __| | .   |  | |   
              | |____| |\  |_| |_     | | | |__| | | \ \| | \ \| |____| |\  |  | |   
              |______|_| \_|_____|    |_|  \____/|_|  \_\_|  \_\______|_| \_|  |_|   
                                                                                     
                                                                                     
                              _____  ______ _____  _      ______     __
                             |  __ \|  ____|  __ \| |    / __ \ \   / /
                             | |  | | |__  | |__) | |   | |  | \ \_/ / 
                             | |  | |  __| |  ___/| |   | |  | |\   /  
                             | |__| | |____| |    | |___| |__| | | |   
                             |_____/|______|_|    |______\____/  |_|
"
}

#DEBUT DU SCRIPT
check
header
#SALLES
write-host "Voici les salles disponibles :"
dsquery OU "$OU"  -o rdn -name 'Salle *' |%{$_ -replace '"', ""} > $TEMP\SALLES_$LogTime.txt #on recupère les salles de OU
$salles = Get-Content $TEMP\SALLES_$LogTime.txt
ForEach ($salles in $salles)
{
	$counter_salles++
	write-host $counter_salles----------$salles -foregroundcolor green #affichage du compteur+salles
}
Do
{
	$NUM = Read-Host "Entrer le numero de salle (0,1,2,...) "
}
while ($NUM -gt $counter_salles)
$salles=Get-content $TEMP\SALLES_$LogTime.txt | Select-Object -Index $NUM # index 0 = ligne 1

#PC
dsquery computer "OU=$salles,$OU" -o rdn |% {$_ -replace '"', ""} > $TEMP\COMPUTERS_$LogTime.txt #on recupère les PC de OU (salles)
write-host
write-host "Voici les PC de cette salle"
$PC=Get-content $TEMP\COMPUTERS_$LogTime.txt # affichage pour verifs
write-host "$PC"  -foregroundcolor green
write-host


#NOM DU COURS
write-host "Voici les cours disponibles :"
Get-ChildItem -path $TORRENT_S -filter *.torrent -name > $TEMP\TORRENT_$LogTime.txt # on liste .torrent
$cours = Get-Content $TEMP\TORRENT_$LogTime.txt
ForEach ($cours in $cours)
{
	$counter_cours++
	write-host $counter_cours----------$cours -foregroundcolor green #affichage du compteur+torrent
}
Do
{
	$NUM = Read-Host "Entrer le numero du cours (0,1,2,...) "
}
while ($NUM -gt $counter_cours)
$FILE=Get-content $TEMP\TORRENT_$LogTime.txt | Select-Object -Index $NUM # index 0 = ligne 1


#DEPLOIEMENT
ForEach ($PC in $PC)
{
	if (Test-Connection -ComputerName $PC -Quiet -Count 2) { #test connexion, si true alors on lance
		write-host "Lancement sur $PC de $FILE ..." -foregroundcolor green
		#LOG
		if ($log) {
			time
			write-output "$time --> Lancement sur $PC de $FILE ..." >> $TEMP\LOG_$LogTime.txt
			}
		# Kill du processus utorrent
		write-host "Kill du processus ..." -foregroundcolor green
		taskkill.exe /S $PC /IM utorrent.exe /T /F | clean
		# creation du repertoire DATA
		write-host "Creation repertoire DATA ..." -foregroundcolor green
		$d = [WMIClass]"\\$PC\root\cimv2:Win32_Process"
		$d.Create("cmd.exe /c md $DATA") | clean
		# creation du repertoire torrent
		write-host "Creation repertoire TORRENT ..." -foregroundcolor green
		$t = [WMIClass]"\\$PC\root\cimv2:Win32_Process"
		$t.Create("cmd.exe /c md $TORRENT_C") | clean
		# copie du .torrent dans rerpertoire torrent
		write-host "Copie du .torrent ..." -foregroundcolor green
		Copy-Item $TORRENT_S\$FILE -Destination \\$PC\C$\torrent\ -force
		# lancement de utorrent et ajout auto du .torrent
		write-host "Lancement de uTorrent ..." -foregroundcolor green
		.$BIN\psexec.exe -accepteula \\$PC -c -v -d -s -i $BIN\uTorrent.exe /HIDE /NOINSTALL /DIRECTORY "$DATA" "$TORRENT_C\$FILE"
	}
	else { #si test NOK, on affiche et on log eventuellement
		write-host "Le $PC ne repond pas !" -foregroundcolor white -backgroundcolor red
		#LOG
		if ($log) {
			time
			write-output "$time --> Le $PC ne repond pas !" >> $TEMP\LOG_$LogTime.txt
			}
		}
}
