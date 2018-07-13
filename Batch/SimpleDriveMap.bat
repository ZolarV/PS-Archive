cls
@ECHO off
ECHO  ********************************* 
ECHO  *                               *
ECHO  * This is to map network drives *
ECHO  *                               *
ECHO  *********************************
ECHO.
ECHO  *********************************
ECHO  * Testing Network Locations     *
ECHO  *********************************   
ECHO.
IF NOT EXIST "H:\home%\%username%" (
SET hdrive="1" && ECHO  H:\ Drive not found 
) ELSE (
ECHO H:\ Drive already mapped
)
IF NOT EXIST "S:\cosshare$"       (
 SET sdrive="1" && ECHO  S:\ Drive not found  
)ELSE (
ECHO S:\ Drive already mapped
)
IF %sdrive%=="1"  (
ECHO --- Mapping Drive Now ---- 
Net use S: "\\ocfile01\cosshare$" /Persistent:YES          
)  
IF %hdrive%=="1" (
ECHO --- Mapping Drive Now ----
Net use H: "\\ocfile01\home$\%username%" /Persistent:YES 
)
Pause
exit