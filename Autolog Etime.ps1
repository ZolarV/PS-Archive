#GetCred
# Boring code
#$u =  Read-Host 'Enter Username'
#$p =  Read-Host 'Enter Password' #-ASSecurestring #lol
# Fun with Functions!
#---- function here 
Function Get-Cred
{
$Creds = @()
$User =  Read-Host 'Enter Username'
$pass =  Read-Host 'Enter Password'
$Creds = @([pscustomObject] @{
        User   = $User 
        Pass   = $Pass 
        })
Return $creds
}

#
$whoami = Read-Host 'Are you Michael?'
If($whoami -ne "Michael"){$Creds = Get-Cred}
else{$Creds = My-Cred}
$u = $Creds.User
$P = $Creds.Pass

$ie = new-object -com InternetExplorer.Application 
#Getsite
$ie.visible = $true 
$SITE = "https://etime.msssolutions.com/etimetrack/"
$ie.navigate2($SITE)
while($ie.busy) {sleep 3} 
#Input Credentials
$user = $ie.Document.getElementByID("txtUsername")
$user.value= "$u"
#Refresh for JAAAVAAA
$button = $ie.Document.getElementsByTagName("INPUT") | Where-Object {$_.value -eq "Cancel"}
$button.click()
#More Credentials
while($ie.busy) {sleep 3} 
$pass = $ie.Document.getElementByID("txtPassword")
#For encryption... not that I care
#decrypt pass to normal string, 4 lines
#$marshal = [System.Runtime.InteropServices.Marshal]
#$ptr = $marshal::SecureStringToBSTR( $p )
#$str = $marshal::PtrToStringBSTR( $ptr )
#$marshal::ZeroFreeBSTR( $ptr )
$pass.value= "$p"
#logs the fuck in
while($ie.busy) {sleep 3} 
$go = $ie.Document.getElementsByTagName("input") | Where-Object {$_.Value -like "login"} 
$go.click()
while($ie.busy) {sleep 3} 
##----- NOW FOR THE FUN PART -Michael Boten/lonely island----##
#Input Batch number
#Gets current Date and finds End of week
$CurrentDate = (Get-Date)
Switch ($currentDate.DayOfWeek){
Monday {$CurrentDate = $CurrentDate.AddDays(4); Break}
Tuesday{$CurrentDate = $CurrentDate.AddDays(3); Break}
Wednesday{$CurrentDate = $CurrentDate.AddDays(2); Break}
Thursday{$CurrentDate = $CurrentDate.AddDays(1); Break}
Friday{$CurrentDate = $CurrentDate.AddDays(0); Break}
Saturday{$CurrentDate = $CurrentDate.AddDays(-1); Break}
Sunday{$CurrentDate = $CurrentDate.AddDays(2); Break}
}
#Formats data for input 
If($CurrentDate.month -le 10 ){$month = "0"+$CurrentDate.month} else {$month = $CurrentDate.month}
$newdate = $month
$newdate += "."
If($CurrentDate.day -le 10 ){$day = "0"+$CurrentDate.day} else {$day = $CurrentDate.day}
$newdate += $day
$newdate += "."
$newdate += ($CurrentDate.year - 2000)
$Wending = "ALL WE " + $Newdate 
#Inputs Batch number for new week
$bin = $ie.Document.getElementById("txtBatchID")
$bin.value = $Wending
$BatchButton = $ie.Document.getElementByID("imgBatchLookup")
$BatchButton.click()
while($ie.busy) {sleep 3} 

#Refresh button
$Refresh = $ie.Document.getElementsByTagName("INPUT") | Where-Object {$_.ID -eq "imgRefresh"}
$Refresh.click()
while($ie.busy) {sleep 2} 
#TRX Type
$TRXTYPE = $ie.Document.getElementsByTagName("INPUT") | Where-Object {$_.value -eq "JC-L"}
$TRXTYPE.value = "UN-L"
#Force Refresh of Page
$save = $ie.Document.getElementByID("imgsave")
$save.click()
while($ie.busy) {sleep 2} 
#Pay Code
$PaYCode = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtPayCode")
$PaYCode.value = "UN"
while($ie.busy) {sleep 2} 
#Equipment GL Account
$PaYCode = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtGLAccountName")
$PaYCode.value = "99-9999-99-999"
while($ie.busy) {sleep 2} 
#Hours  Std 8hr/ 5days
$monday = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtMonHoursUnits")
$monday.value = 8.00
$Tuesday = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtTueHoursUnits")
$Tuesday.value = 8.00
$Weds = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtWedHoursUnits")
$Weds.value = 8.00
$thurs = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtThuHoursUnits")
$thurs.value = 8.00
$fri = $ie.Document.getElementByID("gvWSTimeSheet_ctl02_txtFriHoursUnits")
$fri.value = 8.00
#save 
$save = $ie.Document.getElementByID("imgsave")
$save.click()

# For coding and troubleshooting purposes
#$Batch = $ie.Document.getElementsByTagName("INPUT") | Where-Object {$_.value -eq "Cancel"}
#$export = $ie.Document.getElementsByTagName("INPUT") |Export-Csv -Path "exported.csv"