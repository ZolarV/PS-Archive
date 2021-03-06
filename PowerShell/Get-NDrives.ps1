
Function Get-Ndrives 
{
param([bool]$localflag)
if( $localflag -eq 1 )
    {$compname = Read-host -prompt 'Please input Computername'}
else 
    {$compname = $env:computername}
if(test-path  $home\desktop\getCaption.txt)
    {
    remove-item $home\desktop\getCaption.txt
    remove-item $home\desktop\getUNC.txt
    }
new-item -path  $home\desktop\getCaption.txt -type file
new-item -path  $home\desktop\getUNC.txt -type file
$result = get-wmiobject win32_mappedLogicalDisk -computername $compname | select caption, providername
foreach ($obj in $result){
write-host $obj.caption $obj.providername
add-content $home\desktop\getcaption.txt $obj.caption 
add-content $home\desktop\getunc.txt  $obj.providername
} 
}