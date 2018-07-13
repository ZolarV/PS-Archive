# Author: Michael Curtis
# Date:  10/5/2018
# Version: .5
# Description:  For use with Slack-Bot.  Automating Restarting of applications/services and installing printers/drivers  and Reinstalling Programs

#Restarts All-Scripts  #things that come from slack: VNC and ClientName,   Things that need to come from powershell Creds : Get-Credential
Function Restart-Allscripts{
Param([String]$VNC , [PScredential]$Credential, [String]$clientname)
#get Process and username for Logging
$listprocess = @( (Get-Process -computername $VNC    | Where {$_ -like iexplore.exe}) , $clientname)
#Restarts Process using Invoke
Invoke Command -computername $VNC -credential (get-Credential) -scriptblock {Stop-Process    | Where {$_ -like "iexplore.exe"}}
Invoke Command -computername $VNC -credential (get-Credential) -scriptblock { start-Process   -Filepath "$home\Desktop\Allscriptsxxx.lnk"}
#Restart Process using New-PSsession
New-PSSession -ComputerName $VNC
Stop-Process   | Where {$_ -like "iexplore.exe"}
Start-Process   -Filepath '$home\Desktop\Allscriptsxxx.lnk'

}
#Add Printer
Function ADDPrinting{
Param([String]$VNC , [PScredential]$Credential, [string]$Printer 
#I'm just gonna get their OS remotely
#, [string]$WinXpYesNO
)
$OS= Get-WmiObject -Class win32_OperatingSystem -Credential $credential | select Caption
if(
#$WinXpYesNO.ToUpper() -eq "YES"
$OS.Caption.toupper() -ccontains "XP"
){Add-Printer -ComputerName $VNC  -ConnectionName "\\OCPRINT01\$PrintName"}
Else{Add-Printer -ComputerName $VNC  -ConnectionName "\\OCTWPRINT11\$PrintName"}
}
#Remove Printer
Function RemovePrinter{
Param([String]$VNC , [PScredential]$Credential, [string]$Printer, [string]$WinXpYesNO)
Remove-Printer -ComputerName $VNC -Name $Printer
}
#Set Default
Function DefaultPrinter{
Param([String]$VNC , [PScredential]$Credential, [string]$Printer, [string]$WinXpYesNO)
(Get-WmiObject -class Win32_printer -filter "name = '$printer'").SetDefaultPrinter | Out-Null 
}

## Auto add users to AD and email
# Get First Name, Last Name, Current Username Directory,  and AD user std format on jobname,  location
# 1 check std new username not in Current username DIR,  IF in current username DIR, then add 1 Letter.  
# Create new AD user with valid username, using std format for security and gpo.   Put username in right location based on location info
# Create Email address on exchange server,   add valid email to Username in AD

# Get Ad user type from AD export list,  or find in AD - Users- New users for template
# Assign GPO, Description to variables
# Get name and job type from Track IT server  or slackbot automation
# Compare Jobtype to template - Get right template
# Using name and template  Create new user in AD

