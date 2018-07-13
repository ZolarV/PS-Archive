#Gets Mapped network drives and displays them.
#Needs valid Machine ID or IP address,  return void 

function Get-Shares
{
	Param([string]$machine)
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
}