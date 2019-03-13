# Créé un utilisateur local et l'ajoute dans le groupe Administrateurs.
# Ajoute l'utilisateur actuel dans le groupe administrateurs
# Ajoute le groupe admins_global dans le groupe administrateurs
# Installe la police W92.FON, 
# Copie le raccourcie MFGPRO sur le bureau de l'utilisateur
# Installe Access 97
# Il fait un inventaire du poste
#
#
# Wackou
# contact@wackou.com
# www.wackou.com

#FONCTIONS
function create-account ([string]$accountName = "supporter") { #CREATION COMPTE LOCAL SUPPORTER
	$hostname = hostname
	$comp = [adsi] "WinNT://$hostname" # connexion PC local
	$user = $comp.Create("User", $accountName) #creation de utilisateur
	$user.SetPassword("P@$$w0rd") #ajout du MDP
	$user.SetInfo()
	$user.UserFlags = 64 + 65536 # Le mot de passe ne peut pas etre changé et n'expire jamais
	$user.SetInfo()
	([ADSI]"WinNT://$hostname/Administrateurs,group").Add("WinNT://$hostname/$accountName") #ajout du compte dans le groupe administrateurs
}

function user_local { #AJOUT DU CURRENT USER EN TANT QU'ADMIN
	$user = $env:USERNAME
	$domain = $env:USERDOMAIN
	$hostname = hostname
	$group = [ADSI]"WinNT://$hostname/Administrateurs,group"
	$user_domain = [ADSI]"WinNT://$domain/$user,user"
	$group.Add($user_domain.Path)
}

function AdminGroup { #AJOUT GROUPE admins_global DANS GROUPE ADMINISTRATEURS
	$hostname = hostname
	$domain = $env:USERDOMAIN
	$GroupName = 'Admins_Global'
	$group = [ADSI]"WinNT://$hostname/Administrateurs,group"
	$group_domain = [ADSI]"WinNT://$domain/$GroupName,group"
	$group.Add($group_domain.Path)
}

function police { #COPIE DE POLICE W92.FON SUR LE POSTE
	$FONTS = 0x14
	$Path="c:\fonts"
	$objShell = New-Object -ComObject Shell.Application
	$objFolder = $objShell.Namespace($FONTS)
	New-Item $Path -type directory
	Copy-Item "Y:\W92.FON" $Path
	$Fontdir = dir $Path
	foreach($File in $Fontdir) {
		$objFolder.CopyHere($File.fullname)
	}
}

function mfgpro { #COPIE DE MFGPRO SUR LE POSTE
	$user = $env:USERNAME
	Copy-Item "Y:\MFGPRO.lnk" C:\users\$user\Desktop\
}

function access97 {
Y:\Access97.lnk
}

#Check si droit admin
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
    Write-Warning "This script requires Admin Rights. Please run this script with an account that has sufficient rights."
    exit
}

Write-Host "+--------------------------------+"
Write-Host "¦           Windows 7            ¦" 
Write-Host "¦     post migration script      ¦"
Write-Host "+--------------------------------+"
write-host ""
#APPELS DES FONCTIONS
create-account
write-host "Creation du compte supporter ..."
write-host ""
user_local
write-host "Ajout de l'utilisateur courant dans le groupe Administrateurs ..."
write-host ""
AdminGroup
write-host "Ajout de Admins_Global dans le groupe Administrateurs ..."
write-host ""
police
write-host "Installation de la police W92 ..."
write-host ""
write-host "Installer MFGPRO? o/n"
$mfgpro = Read-Host "->"
if ($mfgpro -eq "o")
	{
	mfgpro
	write-host "Copie de MFGPRO sur le bureau ..."
	write-host ""
	}
write-host "Installer access97? o/n"
$access97 = Read-Host "->"
if ($access97 -eq "o")
	{
	access97
	write-host "Lancement de l'installation d'Access97 ..."
	write-host ""
	}
Y:\ocsinventory.exe /server=http://server_ocs/ocsinventory /np /force /hkcu
write-host "Inventaire du poste sur server_ocs..."
write-host ""
read-host "Press any key to continue ..."
