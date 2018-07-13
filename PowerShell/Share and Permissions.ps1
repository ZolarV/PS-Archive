## Set Shares
## ask user, get machine, test machine.
## 
## Get username
## search for username -> get machine name       Done
## test machine name  -ping machinename   if true then proceed      Done 
## Get mapped drives and display
## Ask drive letter  -> set drive letter and share to MachineName
## Get mapped drives and display
## set security on share for user


## Get username 

$username = Read-Host -prompt 'Please input Username'
if($result = Import-Csv $home/desktop/NameCSV.txt |Where-Object {$_.name -eq $username}) 
{
# Establishes the IP address resolved from the machine name
$machine = $result.machine
if(Test-Connection $machine -Quiet)
{ Write-Host "Uplink Established"} else {Write-Host "Uplink Failed"}
}
else{ Write-Host "Username Not Found"}



## Get maped and disp .  then get drive letter and share and set

$ReturnMapped = get-wmiobject win32_mappedLogicalDisk -computername $machine | select caption, providername
if($ReturnMapped)
{
	write-host "Mapped Drives:"
	foreach ($obj in $ReturnMapped)
	{
	write-host  $obj.caption $obj.providername
	}
}
else
{
Write-Host "No Mapped Drives"
}
# Get the Drive letter and share
$Drive_Letter = Read-host -prompt "Drive letter: "
$Drive_Letter = $Drive_letter + ":"
$Share = Read-Host -prompt "Enter UNC path: "
$Share2 = '"' + $Share + '"'
#Creates the batch file
new-item -path $home\desktop\$username.bat -type file
add-content $home\desktop\$username.bat "net use   $Drive_letter  $Share2 /persistent:yes " 
add-content $home\desktop\$username.bat "pause"
#Zips the file
Compress-Archive -path $home\desktop\$username.bat -CompressionLevel Fastest -DestinationPath $home\desktop\$username


# security and permissions
$Pshare = $Share
$AcessRule = new-object System.Security.AccessControl.FileSystemAccessRule("$username","FullControl","ContainerInherit,ObjectInherit","None","Allow")# "full control can be modified for specific permissions"
$ACL = get-acl $Pshare
$acl.SetAccessRule($AcessRule)
Set-Acl $Pshare -AclObject $ACL

#verify access rules
$ACL = get-acl $Pshare
$ACL.Access