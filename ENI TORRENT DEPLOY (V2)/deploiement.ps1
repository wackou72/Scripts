param($FILE)
$window = (Get-Host).UI.RawUI
$window.WindowTitle = "ENI TORRENT DEPLOY"
$DATA="C:\DATA" # Dossier de destination, les fichiers seront téléchargés ici
$TORRENT_C="C:\torrent" # Dossier contenant les .torrent en destination (client)
$TORRENT_S="TORRENT" #Dossier contenant les .torrents (serveur)
$counter_cours=-1 #Compteur pour le nom du .torrent
$counter_salles=-1 #Compteur pour le nom de la salle
$TEMP="TEMP" #Dossier temporaire pour recevoir les fichiers et logs
$LogTime = Get-Date -Format "dd-MM-yyyy_HH-mm-ss" # obtenir la date des le lancement pour LOG
$log = 1 # 1 ou 0 pour gestion des logs ou non
$BIN="BIN" #Dossier contenant les binaires
$PC=Get-content TEMP\computers.txt # affichage pour verifs
#FONCTIONS
function time{ #Obtenir l'heure lors de l'appel de la fonction (utilise pour les logs)
	$global:time=Get-Date -Format "HH:mm:ss"
}
function clean { #ne pas afficher les messages d'informations
	Select-Object -Property * -ExcludeProperty *
}
ForEach ($PC in $PC)
{
	if (Test-Connection -ComputerName $PC -Quiet -Count 2) { #test connexion, si true alors on lance
		write-host "Lancement sur $PC de $FILE ..." -foregroundcolor green
		#LOG
		if ($log) {
			time
			write-output "$time --> Lancement sur $PC de $FILE ..." >> TEMP\LOG_$LogTime.txt
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
		.$BIN\psexec.exe -accepteula \\$PC -c -v -d -s -i $BIN\uTorrent.exe /NOINSTALL /DIRECTORY "$DATA" "$TORRENT_C\$FILE"
		#/HIDE
	}
	else { #si test NOK, on affiche et on log eventuellement
		write-host "Le $PC ne repond pas !" -foregroundcolor white -backgroundcolor red
				#LOG
		if ($log) {
			time
			write-output "$time --> Le $PC ne repond pas !" >> TEMP\LOG_$LogTime.txt
			}
	}
}
