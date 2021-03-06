
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

Function Set-Ndrives
{
param([BOOL] $getremote)

if($getRemote)
{
$data = read-host -prompt "local[0] or remote[1]?"
[bool] $flag
if($data -eq 1) {$flag = $TRUE} else {$flag= $FALSE} 
& get-ndrives $flag 
}

    
    $capITT =0
    [string[]] $cap2 =@()
    foreach($obj in get-content $home/desktop/getCaption.txt)
        {
        $cap2 += $obj 
        $capITT++ 
        }
    $uncITT=0
    [string[]] $unc2= @()  
    foreach($obj in get-content $home/desktop/getUNC.txt)
        {
        $unc2 += $obj
        $uncITT++
        }
    if($uncITT -eq $capITT)
        {

        for($itt=0 ;$itt -ne ($uncITT +1); $itt++ )
            {
             net use  $cap2[$itt] $unc2[$itt] /persistent:yes
             Write-Host "Set $cap2[$itt] to $unc2[$itt]"
            }
        }
        else{
        Write-host "Network Map Mismatch"
        }
    
 }