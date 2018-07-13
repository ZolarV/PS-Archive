# Written By Michael Curtis
# Date 5/10/2018
# Purpose:  Get AD user group memberships and map appropriate drives to user
# Version 1.0
#
#
#   ------------Start-------------
# 

# Global Variables
# Get Credentials ||  Format:  cos\%username%
$Creds = get-Credential

#Paths
$Std          = "\\octools01\ITTools\LoginScripts\STDuser.bat"
$Operations   = "\\octools01\ITTools\LoginScripts\Operation.bat"
$Trainers     = "\\octools01\ITTools\LoginScripts\Trainer.bat"
$All          = "\\octools01\ITTools\LoginScripts\All.bat"
$remove       = "\\octools01\ITTools\LoginScripts\Remove.bat"

#Possible Operations and Trainers Groups
$TrainersGroup   + @('*Training Team','OC Training', 'Share_TRAINING')
$OperationsGroup = @('*Operations Management','2018 Operations Committee','OSC Operations Share', 'Share_OPERATIONS','ZOperations', 'ZOperationsMgr')

#DEFINE FUNCTIONS
#Set-ADUser Logon Script to $Path known as $membership
 Function Set-Script {
 Param(
  [Parameter(Mandatory=$TRUE)][string] $user ,
  [Parameter(Mandatory=$TRUE)][PSCredential]$Credentials , 
  [Parameter(Mandatory=$TRUE)][string]$membership
  )
   Get-ADUser $user | Set-ADUser -ScriptPath $membership -Credential $Credentials
 }
#Get username
Function Get-User{
$username = Read-Host -Prompt ' Please Input a Username' 
}
# Manual setting,  does not check group membership for permission
Function Manual-Script {
 Param(
  [Parameter(Mandatory=$TRUE)][string] $user ,
  [Parameter(Mandatory=$TRUE)][PSCredential]$Credentials , 
  [Parameter(Mandatory=$TRUE)][string]$membership
  )
  #Gets type
$UserType = Read-Host -Prompt 'Please enter User type: [1] for Std User, [2] for Operations , [3] for Trainers, [4] for All, [5] Remove all mapped drives '
  # hashtag logik'd
 Switch($UserType){
1 { Set-Script($User,$Credentials, $Std ) ; Break}
2 { Set-Script($User,$Credentials, $Operation ) ; Break}
3 { Set-Script($User,$Credentials, $Trainer ) ; Break}
4 { Set-Script($User,$Credentials, $All ) ; Break}
5 { Set-Script($User,$Credentials, $Remove ) ; Break}
Default {Write-Output "Invalid input"; Break}
}
}
#Automatic Settings, Checks group memebership and sets accordingly.  Does not delete
 Function Automatic-Script {
 Param(
  [Parameter(Mandatory=$TRUE)][string] $username ,
  [Parameter(Mandatory=$TRUE)][PSCredential]$Creds
  )
 # Gets group membership of $username
$Groupmembership = (Get-ADPrincipalGroupMembership -Identity $username -Credential $Creds | select Name)
#Automated Check and set.
Foreach($Group in $TrainersGroup)    {IF($Groupmembership | Where-Object {$_.name -like $group} ) { Set-Script($username,$Creds,$Trainer)}}
Foreach($Group in $OperationsGroup)  {IF($Groupmembership | Where-Object {$_.name -like $group} ) { Set-Script($username,$Creds,$Operation)}}
 }

# Menu
While($doagain -eq 0){
  
  Write-Host "Welcome to Networked Drives Automation"
  Write-Host "Type of mapping: 
                Set username   (0)
                Manual         (1)
                Automatic      (2)
                Exit           (3) "
 $choice = Read-Host "Please Select 1,2,3"
 Switch($choice)
       {
        0{$doagain = 1;$user = Get-user   ;BREAK}
        1{$doagain = 1;Manual-Script      ;BREAK}
        2{$doagain = 1;Automatic-Script   ;BREAK}
        3{$doagain = 0 ;BREAK}
        Default{$doagain = 1; Break}
       }
}

# Test/troublshooting commands
#  $thisdomain = Get-ADDomain -Credential $creds -Identity cos.local
#  foreach($_ in $thisdomain.ReplicaDirectoryServers){test-connection -ComputerName $_ -Quiet}
#Get-ADUser $username | Set-ADUser -ScriptPath $thistypepath -Credential $Creds
