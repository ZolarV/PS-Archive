#Written and adapted by Michael Curtis
# Sets time
c:\windows\system32\tzutil /s "Eastern Standard Time"
# Elevates Powershell to admin if not
# Get the ID and security principal of the current user account
#
#$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
#$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
#$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
#if ($myWindowsPrincipal.IsInRole($adminRole))
#   {
   # We are running "as Administrator" - so change the title and background color to indicate this
#   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
#   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
#   clear-host
#   }
#else
#   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
 #  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
 #  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
 #  $newProcess.Verb = "runas";
   
   # Start the new process
 #  [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
  # exit
  # }
 
# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."


#Function for logging adapted from stackedOverflow
#Now including Timestamps :D
Function Write-Log {
#Build log file
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","EXISTS")]
    [String]
    $Level = "EXISTS",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
} 
# Usage : Write-log "PARAM1"  "PARAM2"  "PARAM3"


#Creates directory and log file
New-Item -path c:\ -name "LocalInstaller" -type directory
New-Item  "C:\LocalInstaller\log.txt" -type File
$logfile= "C:\LocalInstaller\log.txt"
#New-item -path "C:\Users\admin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autoupdate.bat" -type file
#$AutoUpdate = "C:\Users\admin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autoupdate.bat"
#if($AutoUpdate)
    #{
    #Add-Content $AutoUpdate -Value "powershell.exe -executionpolicy unrestricted -command set-executionpolicy remotesigned" 
    #Add-Content $AutoUpdate -Value "powershell -executionpolicy Bypass -file C:\users\admin\Desktop\Get-WUInstall.ps1"
    #}
#automatic entry into the domain adapted from stackedOverflow
$domain = "Corp.MSSSolutions.com"
$password = read-host -prompt "set passwsord here" | ConvertTo-SecureString -asPlainText -Force
$username = read-host -prompt "domain\Username Here" 
$username = $domain +"\"+ $username
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $credential
# Test if on successful
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    write-host -fore green "I am domain joined!"
    write-log  "INFO" "Is on domain"
} else {
    write-host -fore red "Failed to join domain!"
    write-log  "INFO" "FAILED to join domain"
}
#Gets sonicwall config file and tests if it exists


if ((Test-Path C:\LocalInstaller\config.txt )) {
    write-log  "INFO" "SonicWall config.txt is in location"
} else {
    write-log  "INFO" "FAILED to copy sonicwall config.txt"
    Copy-Item (\\FS05FILE\Installs\"Sonicwall Installer"\Sonicwall\config.txt -Credential($username,$password)) -Destination C:\LocalInstaller 
}
if ((Test-Path C:\users\admin\desktop\Get-WUInstall.ps1 )) {
    write-log  "INFO" "UpdatePowershell is in location"
} else {
    write-log  "INFO" "FAILED to copy sonicwall config.txt"
    Copy-Item (\\FS05FILE\Installs\"User Installers"\Scripts\Get-WUInstall.ps1 -Credential($username,$password)) -Destination C:\users\admin\Desktop
   
}
# Main Installer Body
# | ******************************************************************************************|
# | TO DO:                                                                                    |
# | Generalize list of locations to readin a txt file  and pipe to function that installs     |
# | ******************************************************************************************|
# Location to variable assignment
$L1 =  "C:\Program Files (x86)\Symantec" #Antivirus
$L2 =  "C:\Program Files\Dell SonicWALL" #Sonicwall
$L3 =  "C:\Program Files (x86)\Microsoft Office" #Office365
$L4 =  "C:\Program Files\Autodesk"#TrueView Installer
$locations = $L1, $L2, $L3, $L4 #array of locations for installations
$it = 0 # counter for total programs installed
foreach ( $loc in $locations)
{
   #Gets architecture for version.
   [bool] $Vers = read-host -prompt "BOOL [0]x64, [1]x86"
   Write-log "INFO" "Computer is $Vers : 0]x64, [1]x86"
   
    if(-NOT (Test-Path $loc)) 
    {
    $it++
        
        Write-Log "INFO" "Installing program to: $Loc" $logfile
        
        
       if ($loc -eq $L1)
       
                if($vers)
                    {
                     \\FS05FILE\Installs\"Symantec Antivirus Clients\Antivirus 12 Clients\12.1.6\x64"\setup.exe -credential($username,$password)   
                    }
                else
                    {
                    \\FS05FILE\Installs\"Symantec Antivirus Clients\Antivirus 12 Clients\12.1.6\x86"\setup.exe -credential($username,$password)   
                    }
        if ($loc -eq $L2)
            { 
                
                if($vers)
                    {
                     \\FS05FILE\Installs\"Sonicwall Installer"\Sonicwall\64bit_4.9.40306_EN.exe -credential($username,$password)   
                    }
                else
                    {
                     \\FS05FILE\Installs\"Sonicwall Installer"\Sonicwall\32bit_4.9.40306_EN.exe -credential($username,$password)   
                    }
       
        if ($loc -eq $L3)
            {
             \\FS05FILE\Installs\"Microsoft Office Suite"\365\setup.x86.en-us_2016.exe -credential($username,$password) 
            }
       
        if ($loc -eq $L4)
                    {
                if($vers)
                    {
                    \\FS05FILE\Installs\Autodesk\"DWG Trueview 2016"\64Bit\Setup.exe -credential($username,$password)   
                    }
                else
                    {
                    \\FS05FILE\Installs\"Autodesk\DWG Trueview 2016"\32Bit\Setup.exe -credential($username,$password)   
                    }
             }
    else 
    {
    Write-log "EXISTS" "Program found, Skipping installation" $logfile
    Write-log "EXISTS" $loc $logfile
    }
}
Write-log "INFO" "Program(s) Installed: $it" $logfile #Logs total Programs installed

#Opens sys properties to allow VPN under most insecure.
C:\windows\system32\SystemPropertiesRemote.exe
#Opens log
Invoke-Item "C:\LocalInstaller\log.txt"
#Restarts Local Computer, requires confirmation
Restart-Computer -Confirm

#***************************************#
#|  TO DO:                              |
#|  ADD Windows Update Code             |                                                        
#|                                      |
#***************************************#

#Legacy Code
#Copy-Item \\FS05FILE\Installs\"Sonicwall Installer"\Sonicwall\config.txt -Destination C:\LocalInstaller
#Copy-Item \\FS05FIle\Installs\"User Installers"\LaptopInstallsBasic\Installer.bat -Destination C:\LocalInstaller
#C:\LocalInstaller\Installer.bat

#Legacy Code for automatic entry into the domain adapted from stackedOverflow
#$domain = "Corp.MSSSolutions.com"
#$password = " set passwsord here" | ConvertTo-SecureString -asPlainText -Force
#$username = "$domain\ Username Here" 
#$credential = New-Object System.Management.Automation.PSCredential($username,$password)
#Add-Computer -DomainName $domain -Credential $credential