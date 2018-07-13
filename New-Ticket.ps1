#Get site
function New-Ticket {

Param([string]$site)
$ie = New-Webpage -page $site 
$ie.Document.IHTMLDocument3_getElementById("uname").value = $crds.User
$ie.Document.IHTMLDocument3_getElementById("pword").value = $crds.Pass
$ie.Document.IHTMLDocument3_getElementById("button").click()

Write-Host "What would you like to do?"
Write-host "Options:
                Read  Tickets  (1)
                Enter Tickets  (2)
                Close Tickets  (3)"
$input =  Read-Host "Input Selection: "
Switch ($input)
{
1{New-Webpage -page "http://192.168.2.235/portal/help/admin/admin_open.asp"   ;Break}
2{New-Webpage -page "http://192.168.2.235/portal/help/admin/enternew.asp"     ;Break}
3{New-Webpage -page "http://192.168.2.235/portal/help/admin/admin_open.asp"    ;Break}
}
}

