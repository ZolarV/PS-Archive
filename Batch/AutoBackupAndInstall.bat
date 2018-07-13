cls
@ECHO off
ECHO  ********************************* 
ECHO  *         Purpose:              *
ECHO  *	 Backup Files to H drive &    *
ECHO  * run Sophos Encryption script  *
ECHO  *                               *
ECHO  *********************************
ECHO.
ECHO  *********************************
ECHO  *      Testing H Drive          *
ECHO  *********************************   
ECHO.

IF NOT EXIST "H:\Home$\%username%" (
SET hdrive="1" && ECHO  H:\ Drive not found 
) ELSE (
ECHO H:\ Drive already mapped
)

ECHO.
ECHO  *********************************
ECHO  *       Mapping H Drive         *
ECHO  *********************************   
ECHO.

IF %hdrive%=="1" (
ECHO --- Mapping Drive Now ----
Net use H: "\\ocfile01\home$\%username%" /Persistent:YES 
)

ECHO.
ECHO  *********************************
ECHO  *    Creating Backup folder     *
ECHO  *********************************   
ECHO.

CD "H:\"
Mkdir "BackupFolder_99"

ECHO.
ECHO  *********************************
ECHO  *          Copy files           *
ECHO  *********************************   
ECHO.


XCOPY "C:\users\%username%" "H:\BackupFolder_99" /E

ECHO.
ECHO  *********************************
ECHO  *        Begin Encryption       *
ECHO  *********************************   
ECHO.

:again 
   echo.
   set /p answer=Begin Encryption (Y/N)?
   if /i "%answer:~,1%" EQU "Y" goto begin
   if /i "%answer:~,1%" EQU "N" exit /b
   echo Please type Y for Yes or N for No
   goto again


:begin
ECHO.
ECHO  *********************************
ECHO  *     Install Preq's Silent     *
ECHO  *********************************   
ECHO.
ECHO  *     KB Silent Install     *
  wusa.exe "\\octools01\Software\Onsite IT\Sophos SafeGuard\Scripted Installer\Windows6.1-KB2999226-x64.msu" /quiet
ECHO  *     VC_redist Silent Install     *
  "\\octools01\Software\Onsite IT\Sophos SafeGuard\Scripted Installer\vc_redist.x86.exe" /install /passive /quiet
ECHO  *     .NetFx45 Siletn Install     *
"\\octools01\Software\Onsite IT\Sophos SafeGuard\Scripted Installer\dotNetFx45_Full_setup.exe" /install /passive 

ECHO.
ECHO  *********************************
ECHO  *       Run SGN 8 Script        *
ECHO  *********************************   
ECHO.
  "\\octools01\Software\Onsite IT\Sophos SafeGuard\Scripted Installer\SGN 8  Install Script.vbs"