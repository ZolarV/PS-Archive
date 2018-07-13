# Author:    Michael Curtis
# Date:      5/10/2018
# Version:   .5
# Purpose:   Get computer and user details using GWMI for inventory
#
# Stuff it gets: 
#        Asset-Tag    located in Computer Description field
#        Serial
#        OS           FIELD: caption                                   : Microsoft Windows 10 Education    in WIN32_ OperatingSystem
#        Architecture FIELD: OSArchitecture                            : 64-bit in Win32_OperatingSystem
#        Select Drivers                                                : I have not built this yet
#        Network adapters (mac addys)
#        Computer Name
#    


#Global Variable Defines
$AssetList = @([pscustomobject] @{ 
ComputerName = "" 
Serial = ""
AssetTag = ""
OS = ""
Architecture = ""
MacAddress =""
})
$OUpaths = @([pscustomobject] @{ 
Location = "" 
type = ""
DC = ""
})
$OutputArray = @([pscustomobject] @{ 
AssetTag = "" 
Serial = ""
OS = ""
Architecture = ""
NetworkAdaptor = ""
ComputerName = ""
IP = ""
})
[System.Collections.ArrayList]$LocationList = @()
[System.Collections.ArrayList]$errorList = @()

#menu for doing stuff
While($doagain -eq 0){
  Write-Host "Welcome to Asset List Automation"
  Write-Host "Please Select your mode: 
                Credentials    (1)
                Automatic      (2)
                Exit           (3)    "
 $choice = Read-Host "Please Select 1,2,3"
 Switch($choice)
       {
        1{$doagain = 1;$Creds = Get-Credential ;BREAK}
        2{$doagain = 1;Auto-AssetList          ;BREAK}
        3{$doagain = 0                         ;BREAK}
        Default{Write-Host "Invalid Input"     ;Break}
       }
}

# Function "main" if you will.  Primary function for doing all the things. 
function Auto-AssetList($credentials) {
#clears the objects
$oupaths.clear()
$searchbase.clear()
$OutputArray.clear()
#creates each custom searchbase per location
foreach($Location in $Global:locationlist){
$OUpaths += $OUPaths  + @([pscustomobject] @{ 
Location = $Location 
type = "Laptops"
DC = "cos.local"
})
$OUpaths += $OUPaths  + @([pscustomobject] @{ 
Location = $Location 
type = "Desktops"
DC = "cos.local"
})
}

foreach($currentOU in $OUpaths){
#formates it as a single string object
if($currentOU.type = "Laptops"){
$searchbase += "OU="+($currentOU.location) +","+ "OU=Laptops," + "DC="+$currentOU.DC
$laptops += Get-ADcomputer -Filter * -searchbase $searchbase
}
if($currentOU.type = "Desktops"){
$searchbase += "OU="+($currentOU.location) +","+ "OU=Desktops," + "DC="+$currentOU.DC
$desktops += Get-ADcomputer -Filter * -searchbase $searchbase
}
}

#Uses function to get info exports data
Get-Info($Laptops)
$outputArray | Export-Csv $home\desktop\LaptopsInven.CSV -NoTypeInformation

$OutputArray.clear()
#Uses function to get info exports data
Get-Info($Desktops)
$outputArray | Export-Csv $home\desktop\desktopsInvin.CSV -NoTypeInformation

}

# Gets computer information,  can edit here to add or remove items you want. 
function Get-info($list){
Foreach($computer in $list){
try{
$WinOS =Get-WmiObject win32_OperatingSystem -ComputerName $computer -credential $Creds  | Select PSComputerName ,Status , Caption , OSArchitecture, Description 
#  For use later in getting all running processes  (E.G. killing processes) 
#  $WinProcess =Get-WmiObject win32_Process -ComputerName $computer -credential $Creds  | Select Name, csname, Caption

$WinNetAdapt =Get-WmiObject Win32_networkAdapter -ComputerName $computer -credential $Creds   | Where-Object {$_.Name -like "Intel*"}  | select ServiceName, MACAddress
# For use later in getting specific drivers  E.G. Mmodel and whatever. 
#$Windriver =Get-WmiObject Win32_SystemDriver -ComputerName OCHKYPC005 -credential $Creds  | select  DisplayName, Name

$OutputArray += $OutputArray + @([pscustomobject] @{ 
AssetTag = $winOS.Caption 
Serial = ""
OS = $winOS.Caption
Architecture = $WinOS.Architecture
MACAddress = $WinNetAdept.MACAddress
ComputerName = $winOS.PSComputerName
IP = [System.Net.Dns]::GetHostAddresses($winOS.PSComputerName).IPAddressToString
})
}
catch{
$errorlist.add($computer)
}
}
}


# Gets location lists for use in grabbing computer list from AD
function Get-LocationList(){
$doagain = 0
 Write-Host "Please enter all your locations you need to inventory:
             E.G.:   Hickory
                 :   Boone
                 :   Ballentyne
                 :   Park rd
             Warning: Location must be a valid AD object in 'Domain Computers'"
While($doagain -eq 0){       
   Write-Host "Please Select your mode: 
                Add Location    (o)
                Clear list      (1)
                Show  list      (2)
                Exit            (3)"
   $choice = Read-Host "Please Select 0,1"
   Switch($choice)
       {
        0{$doagain = 0; $Global:locationlist.add( (Read-host "Add Location:")) ;BREAK}
        1{$doagain = 0; $Global:locationlist =@()}
        2{$doagain = 0; -join $Global:locationlist }
        3{$doagain = 1;BREAK}
        Default{Write-Host "Invalid Input"     ;Break}
        
       } 
   }
}



# Primary Data getting functions and various meat.
# canonical name of object cos.loca/domain computers/Type/location  
# $thistype = Read-host "Please type your OU for querrying PC's"
# Get-ADComputer -Filter * -SearchBase "OU= $ThisType, DC= cos.local"
# Get-WmiObject win32_OperatingSystem -ComputerName $computer -credential $Creds  | Select PSComputerName ,Status , Caption , OSArchitecture, Description 
# Get-WmiObject win32_Process -ComputerName $computer -credential $Creds  | Select Name, csname, Caption
# Get-WmiObject Win32_networkAdapter -ComputerName OCHKYPC005 -credential $Creds   | Where-Object {$_.Name -like "Intel*"}  | select ServiceName, MACAddress
# Get-WmiObject Win32_SystemDriver -ComputerName OCHKYPC005 -credential $Creds  | select  DisplayName, Name