# Ce script créé des dossiers utilisateurs à partir d'une liste venant de AD
# Il ajoute les droits de l'utilisateur/admin/system sur son dossier (full access)
# Il place un quota sur le dossier
# 
# environnement : Windows 2008R2 + FSRM
#
# Wackou
# contact@wackou.com
# www.wackou.com
#
#variables
$lecteur="D:" #lecteur où les dossiers seront créés
$Tquotas="quota" #variable qui sert de template pour les quotas

#debut script
$fichier = Get-Content utilisateurs.txt #importation des utilisateurs à partir de utilisateurs.txt
	$utilisateurs = $fichier
	Foreach ($utilisateurs in $fichier)
	{
	New-Item $lecteur\$utilisateurs -type directory #on créé le dossier de l'utilisateur en fonction de la variable
	& icacls $lecteur\$utilisateurs /inheritance:r /t /grant:r Admins_Global:`(OI`)`(CI`)F /c /q #Droits Administrateurs
	& icacls $lecteur\$utilisateurs /inheritance:r /t /grant:r System:`(OI`)`(CI`)F /c /q #Droits systeme
	& icacls $lecteur\$utilisateurs /inheritance:r /t /grant:r $utilisateurs':(OI)(CI)F' /c /q #Droits utilisateur sur son dossier
	dirquota quota add /path:"$lecteur\$utilisateurs" /sourcetemplate:"$Tquotas" #on place les quotas sur chaque dossier utilisateurs
	}
