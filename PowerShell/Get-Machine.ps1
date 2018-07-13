# Function that connects username with Machine ID and translates to IP

Function Get-Machine
{
$username = Read-Host -prompt 'Please input Username'
if($result = Import-Csv $home/desktop/NameCSV.txt |Where-Object {$_.name -eq $username}) 
{
	#Establishes the IP address resolved from the machine name
	$Machine = $result.machine
	if(Test-Connection $Machine -Quiet)
	{ 
		Write-Host "Uplink to $username Established"
		write-Host "Machine ID: "$Machine
	} 	
	else 
	{
		Write-Host "Uplink to $username Failed"
	}
}
else
{ 
	Write-Host "Username Not Found"
}




return($username,$machine)

}