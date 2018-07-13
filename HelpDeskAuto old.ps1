#Stupid function

Function New-Webpage
{
 Param([Parameter(Mandatory=$TRUE)][String]$page)

$ie = new-object -com InternetExplorer.Application 
$ie.visible = $true 
$ie.navigate2($page)
return $ie
}

#MSS Helpdesk Automation
#Get where
$Choice = ""
$crds =@([pscustomObject] @{
        User   =  "itgroup" 
        Pass   =  "helpme"})
$crd2s =@([pscustomObject] @{
        User   =  "John.White@msssolutions" 
        Pass   =  "Tuck1001"})
Write-Host "Welcome to MSS Helpdesk Automation"
Write-Host "Portal Locations:"
Write-Host "
            HelpDesk Admin    (1)
            Assett Management (2)
            New Hire          (3)"
$choice = Read-Host "Please Select 1,2,or 3:"
Switch($choice)
{
1 {New-Ticket($crds) -site  "http://192.168.2.235/portal/help/" ;BREAK}
2 {ASS($crds)        -site  "http://192.168.2.235/portal/inv/" ;BREAK}
3 {NEW-HIRE($crd2s)  -site  "http://192.168.2.235/portal/newhire/" ;BREAK}
}


