REM Script pour mettre à jour un logiciel
REM Test si OS 32/64 puis test la présence de fichier, si oui alors on lance le processus de desinstallation puis installation de la nouvelle version
REM Enregistrement des DLL du logiciel
REM Wackou
REM contact@wackou.com
REM www.wackou.com
@echo off
cls
REM Initilisation variables
REM Obtention de la date, indépendamment de la langue du poste
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%_%DTS:~8,2%-%DTS:~10,2%
REM Chemin où se trouve les fichiers
set FOLDER=\\dc1.domain.local\software
REM Fichier de log, format COMPUTER_DOMAIN_USERNAME_20160119_15-31-14.log
set LOG_FILE=%COMPUTERNAME%_%USERDOMAIN%_%USERNAME%_%DATE%.log
REM Dossier où les logs seront enregistrés
set LOG_FOLDER=%FOLDER%\Logs
REM Kit installation 32 Bits et 64 Bits
set INSTALL64=%FOLDER%\Setup\install64
set INSTALL32=%FOLDER%\Setup\install32
REM Chemin de .DLL
set DLL=%FOLDER%\Setup\DLL.dll
REM Dossier contenant des fichiers de traduction
set FILES=%FOLDER%\Setup\Files
REM ID package MSI de l'ancienne et la nouvelle version
set ID_OLD_V={436F3D0A-3994-4883-B5C8-761B9071B7CA}
set ID_NEW_V={451A01D7-7124-4F03-9E8D-B3B387D39F7F}
REM Dossiers installation OS 64 Bits
set DIR64=%ProgramFiles%\software\folder
set DIR32=%ProgramFiles(x86)%\software\folder
REM Dossier installation OS 32 Bits
set DIR=%DIR64%

REM Debut du programme
echo Script starting at %time:~0,2%-%time:~3,2%-%time:~6,2% >> "%LOG_FOLDER%\%LOG_FILE%"
REM Verification si 32 Bits ou 64 Bits
if "%PROCESSOR_ARCHITECTURE%" == "x86" (
	echo System is 32 bits >> "%LOG_FOLDER%\%LOG_FILE%"
goto CHK32
) else (
	echo System is 64 bits >> "%LOG_FOLDER%\%LOG_FILE%"
goto CHK64
)
REM Verification version installée
:CHK64
if exist "%DIR32%\file1.tlb" (
	if exist "%DIR32%\file2.tlb" (
		if exist "%DIR64%\file1.tlb" (
			if exist "%DIR64%\file2.tlb" (
			REM Si tous les tests sont OK, alors c'est la version 64 bits qui est présente
			echo "File1 (32/64 Bits) and File2 (32/64 Bits) found" >> "%LOG_FOLDER%\%LOG_FILE%"
			goto INST64
			)
		)
	)
)
goto NTD
:CHK32
if exist "%DIR%\file1.tlb" (
	if exist "%DIR%\file2.tlb" (
			REM Si tous les tests sont OK, alors c'est la version 32 bits qui est présente
			echo "File1 (32 Bits) and File2 (32 Bits) found" >> "%LOG_FOLDER%\%LOG_FILE%"
			goto INST32
	)
)
goto NTD
REM Installation 64 Bits
:INST64
echo Starting to uninstall old version (64 Bits) >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\msiexec.exe /x %ID_OLD_V% /quiet
echo Cleaning folder 32 Bits and 64 Bits >> "%LOG_FOLDER%\%LOG_FILE%"
DEL "%DIR32%\*.*" /F /Q
DEL "%DIR64%\*.*" /F /Q
echo Starting to install new version (64 Bits) >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\msiexec.exe /i "%INSTALL64%\Setup_Client.msi" /quiet
if not exist "%ProgramFiles%\software" mkdir "%ProgramFiles%\software" >> "%LOG_FOLDER%\%LOG_FILE%"
if not exist "%ProgramFiles%\software\folder" mkdir "%ProgramFiles%\software\folder" >> "%LOG_FOLDER%\%LOG_FILE%"
echo Copy %DLL% to %DIR32% >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\xcopy.exe "%DLL%" "%DIR32%" /h /c /k /q >> "%LOG_FOLDER%\%LOG_FILE%"
echo Copy %FILES% to %DIR32% >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\xcopy.exe "%FILES%" "%DIR32%" /h /c /k /q /y /s >> "%LOG_FOLDER%\%LOG_FILE%"
echo Copy %DIR32% to %DIR64% >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\xcopy.exe "%DIR32%" "%DIR64%" /h /e /c /k /q >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR64%\DLL.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR32%\DLL.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\regasm.exe" "%DIR64%\DLL2.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\regasm.exe" "%DIR32%\DLL2.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR64%\DLL3.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR32%\DLL3.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
REM Creation du fichier d'information pour les utilisateurs
echo New version has been installed >> "%DIR32%\000.txt"
echo New version has been installed >> "%DIR64%\000.txt"
goto END
REM Installation 32 Bits
:INST32
echo Starting to uninstall old version (32 Bits) >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\msiexec.exe /x %ID_OLD_V% /quiet
echo Cleaning folder 32 Bits >> "%LOG_FOLDER%\%LOG_FILE%"
REM Provoque une erreur en interactif car le dossier est déjà supprimé par la desinstallation
REM DEL "%DIR%\*.*" /F /Q
echo Starting to install new version (32 Bits) >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\msiexec.exe /i "%INSTALL32%\Setup_Client.msi" /quiet
echo Copy %DLL% to %DIR% >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\xcopy.exe "%DLL%" "%DIR%" /h /c /k /q >> "%LOG_FOLDER%\%LOG_FILE%"
echo Copy %FILES% to %DIR% >> "%LOG_FOLDER%\%LOG_FILE%"
%windir%\System32\xcopy.exe "%FILES%" "%DIR%" /h /c /k /q /y /s >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR%\DLL.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" "%DIR%\DLL2.dll" /codebase /silent >> "%LOG_FOLDER%\%LOG_FILE%"
REM Creation du fichier d'information pour les utilisateurs
echo New version has been installed >> "%DIR%\000.txt"
goto END
:NTD
echo Nothing to do >> "%LOG_FOLDER%\%LOG_FILE%"
REM Test si nouvelle version installée
for /f "tokens=2*" %%a in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ID_NEW_V%" /v displayversion 2^>nul') do echo Version is %%b (New) >> "%LOG_FOLDER%\%LOG_FILE%"
REM Test si ancienne version installée
for /f "tokens=2*" %%a in ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ID_OLD_V%" /v displayversion 2^>nul') do echo Version is %%b (Old) >> "%LOG_FOLDER%\%LOG_FILE%"
goto END
:END
echo Script ending at %time:~0,2%-%time:~3,2%-%time:~6,2% >> "%LOG_FOLDER%\%LOG_FILE%"
