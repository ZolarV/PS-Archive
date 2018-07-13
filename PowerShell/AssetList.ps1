# Author:    Michael Curtis
# Date:      5/10/2018
# Version:   .1
# Purpose:   Get OS, Computer, user details using GWMI
#
# TO Do: 
#        Asset-Tag located in Computer Description field
#        Serial
#        OS           FIELD: caption                                   : Microsoft Windows 10 Education    in WIN32_ OperatingSystem
#        Architecture FIELD: OSArchitecture                            : 64-bit in Win32_OperatingSystem
#        Select Drivers                                                : I have not built this yet
#        Network adapters (mac addys)
#        Computer Name
#     Possibly use AD to get List of PC's, ask. 


#Create Custom Array for storage
$AssetList = @([pscustomobject] @{ 
ComputerName = "" 
Serial = ""
AssetTag = ""
OS = ""
Architecture = ""
MacAddress =""
})

#Get admin creds
$Creds = Get-Credential






$thistype = Read-host "Please type your OU for querrying PC's"

Get-ADComputer -Filter * -SearchBase "OU= $ThisType, DC= cos.local"

Get-WmiObject win32_OperatingSystem -ComputerName $computer -credential $Creds  | Select PSComputerName ,Status , Caption , OSArchitecture, Description 

Get-WmiObject win32_Process -ComputerName $computer -credential $Creds  | Select Name, csname, Caption

Get-WmiObject Win32_networkAdapter -ComputerName OCHKYPC005 -credential $Creds   | Where-Object {$_.Name -like "Intel*"}  | select ServiceName, MACAddress
Get-WmiObject Win32_SystemDriver -ComputerName OCHKYPC005 -credential $Creds  | select  DisplayName, Name












# Using, Computername, OS, Architechture  - Install Printer Drivers From //OCxxPrintxx 

#Two Functions : auto import from .csv  | manual mode








# Menu
While($doagain -eq 0){


  Write-Host "Welcome to Asset List Automation"
  Write-Host "Please Select your mode: 
                Credentials    (o)
                Manual         (1)
                Automatic      (2)
                Exit           (3)    "
 $choice = Read-Host "Please Select 1,2,3"
 Switch($choice)
       {
        0{$doagain = 1;$Creds = Get-Credential ;BREAK}
        1{$doagain = 1;Manual-AssetList        ;BREAK}
        2{$doagain = 1;Auto-AssetList          ;BREAK}
        3{$doagain = 0                         ;BREAK}
        Default{Write-Host "Invalid Input"     ;Break}
       }
}

Function Auto-AssetList{
$WMIlist = @('Win32_OperatingSystem','Win32_ComputerSystem','Win32_NetworkAdapter','Win32_SystemDriver','Win32_Process')
$Importlist = Import-Csv -Path (Read-Host -Prompt "Please enter exact path to PC list") -Header
Foreach($PC in $Importlist) {   
foreach($WMI in $WMIlist){
$this = Get-WmiObject -class $WMI  -ComputerName $PC -Credential $Creds | select * 

Switch($WMI)
{
    'Win32_OperatingSystem'{$AssetList[$itt].Architecture = $this.OSArchitecture ; BREAK}

}


}
Function Manual-AssetList{



}