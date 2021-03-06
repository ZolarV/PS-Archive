#Constants  Webpages
$ReadTicket   =  "http://192.168.2.235/portal/help/admin/admin_open.asp"
$NewTicket    =  "http://192.168.2.235/portal/help/admin/enternew.asp"
$MainASS      =  "http://192.168.2.235/portal/inv/main_item.asp"
$NewASS       =  "http://192.168.2.235/portal/inv/newasset.asp"
$HelpPortal   =  "http://192.168.2.235/portal/help/"
$AssPortal    =  "http://192.168.2.235/portal/inv/"
$HirePortal   =  "http://192.168.2.235/portal/newhire/"
#SQL Constants
$SQLServer = "fs04sql"
#SQL Databases
$SQLDBName = "inventory"
$HIREdb = "NewHire" 
# SQL Creds
$uid = "portaluser";$pwd = "Tuck1001"
# Laptop list
[System.Collections.ArrayList] $Laptops ="Latitude E5450","Latitude E5480","Latitude E5550"
#Laptop Function
Function Get-Laptop {
Param([Parameter(Mandatory=$TRUE)][String]$Department)
Switch($Department){
"IT"                      {$ThisLaptop =$Laptops[0] ;Break}
"Administration"          {$ThisLaptop =$Laptops[0] ;Break}
"Mechanical Construction" {$ThisLaptop =$Laptops[0] ;Break}
"Controls"                {$ThisLaptop =$Laptops[3] ;Break}
"Fire and Security"       {$ThisLaptop =$Laptops[0] ;Break}
"Project Management"      {$ThisLaptop =$Laptops[0] ;Break}
"Sales"                   {$ThisLaptop =$Laptops[0] ;Break}
"Service"                 {$ThisLaptop =$Laptops[0] ;Break}
Default                   {$ThisLaptop =$Laptops[0] ;Break}
}
Return $ThisLaptop
}
#function for editing Laptop list
function Laptop-List{
$again = 0
While($again -eq 0){
 Write-Host "What would you like to do?"
 Write-host "Options:
                See List      (1)
                Edit List     (2)
                Clear List    (3)
                Add List      (4)
                Save List     (5)"
        $input =  Read-Host "Input Selection:"
        Switch ($input)
        {1{foreach($_ in $Laptops){$_}  
        Write-host "Laptop Assignment By Department using INDEX
                            IT                         0
                            Administration             0
                            Mechanical Construction    0
                            Control                    3
                            Fire and Security          0
                            Project Management         0
                            Sales                      0
                            Service                    0"
        }
         2{Edit-Laptop -Which (Read-host -Prompt "Enter a Laptop you wish to remove");break}
         3{$laptops.clear();break}
         4{$Laptops.Add((Read-host -Prompt "Enter Laptop to add"));break}
         5{$SearchString = '[System.Collections.ArrayList] $Laptops =' 
            for($i=0; $i -lt $laptops.count; $i++)
                { 
                if($i -eq $laptops.count -1) {$SearchString += ('"'+ $laptops[$i] +'"')}
                else{$SearchString += ('"'+ $laptops[$i]  +'",')}
                }
            $temp = Get-content $PSScriptRoot\HelpDeskAuto.ps1
            $Temp | out-file $home\desktop\temp.txt
            [System.Collections.ArrayList] $temp2 = get-content -path $home\desktop\temp.txt
            $k =  $temp2.IndexOf($OLDLaptopList);  
            $temp2.RemoveAt($k); $temp2.Insert($k,$SearchString)
            $temp2 | Out-File $PSScriptRoot\HelpDeskAuto.ps1 -Force
            . $PSScriptRoot\HelpDeskAuto.ps1
               ;break
              }
          Default{$again = 1; Break}
        }
}
}
# Edit Laptop List function
Function Edit-Laptop{
Param([Parameter(Mandatory=$TRUE)][String]$Which)
for ($i = 0; $i -lt $laptops.Count; $i++){if($laptops[$i] -eq $which){$Laptops.RemoveAt($i); $i--}}
Return $Laptops
}
# Saves laptop List


# SQL and Data
Function GETSQL-INV {
# SQL connect to inventory database
$sqlConn = New-Object System.Data.SqlClient.SqlConnection
$SqlConn.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; User ID = $uid; Password = $pwd;";$sqlConn.Open()
$Query = "SELECT [MSSID] FROM [ITEMLIST]" ; $sqlcmd = $sqlConn.CreateCommand();$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd; $data = New-Object System.Data.DataSet 
$adp.Fill($data) |Out-Null
$LastID = $data.tables.rows[$data.tables.rows.Count - 1].MSSID
$sqlConn.close()
Return $LastID
}
FUNCTION GETSQL-NEWHIRE{
#SQL connect to Newhire database
$SQLHIREcon = New-Object System.Data.SqlClient.SqlConnection
$SQLHIREcon.ConnectionString = "Server = $SQLServer; Database = $hiredb; User ID = $uid; Password = $pwd;"
$SQLHIREcon.Open()
$HireQuery = 
"
select  namelast, namefirst, position, division, knownasfirst, laptop, (namelast + ' '+ namefirst) AS FULLNAME
from tbl_newhire
where
 ([startdate] BETWEEN DATEADD(DAY,-14, GETDATE()) AND  DATEADD(DAY,14, GETDATE())) 
 AND (([laptop] != 0) OR ([desktop] !=0))
 AND(
	   rtrim(namelast) + ' ' + rtrim(namefirst) not in (select rtrim(issuedto) from inventory.dbo.itemlist)
	or rtrim(namelast) + ' ' + rtrim(knownasfirst) not in (select rtrim(issuedto) from inventory.dbo.itemlist)
 );
"
$hireCMD = $SQLHIREcon.CreateCommand()
$hireCMD.CommandText =$HireQuery
$HireADP = New-Object System.Data.SqlClient.SqlDataAdapter $hireCMD
$HireDATA = New-Object System.Data.DataSet 
$HireADP.Fill($HireDATA) |Out-Null
$outdata = $HireDATA.tables
$SQLHIREcon.close()
Return $outdata
}

#Stupid function
Function New-Webpage{
Param([Parameter(Mandatory=$TRUE)][String]$page, [Parameter(Mandatory=$false)][int]$vis)
    $ie = new-object -com InternetExplorer.Application 
    if($vis -eq 0){ $ie.visible = $true} 
    else{$ie.visible = $false} 
    $ie.navigate2($page)
return $ie
}
#Get site
function New-Ticket {
Param([string]$site)
    $NewAgain = 0
    $ie = New-Webpage -page $site 
    $ie.Document.IHTMLDocument3_getElementById("uname").value = $crds.User
    $ie.Document.IHTMLDocument3_getElementById("pword").value = $crds.Pass
    $ie.Document.IHTMLDocument3_getElementById("button").click()
    While($NewAgain -eq 0){
        Write-Host "What would you like to do?"
        Write-host "Options:
                Read  Tickets  (1)
                Enter Tickets  (2)
                Close Tickets  (3)
                Stop           (4)"
        $input =  Read-Host "Input Selection:"
        Switch ($input)
        {
         1{$NewAgain = 0;$obj = New-Webpage -page $ReadTicket    ;Break}
         2{$NewAgain = 0;$obj = New-Webpage -page $NewTicket     ;Break}
         3{$NewAgain = 0;$obj = New-Webpage -page $ReadTicket    ;Break}
         Default{$NewAgain = 1; Break}
        }
    }
}
#Another Stupid Function
Function Ass-Man{
Param([string]$site)
    $ASSagain =0;
    $ie = New-Webpage -page $site 
    $ie.Document.IHTMLDocument3_getElementById("username").value = $crds.User
    $ie.Document.IHTMLDocument3_getElementById("password").value = $crds.Pass
    $ie.Document.IHTMLDocument3_getElementById("button").click()
    While($ASSagain -eq 0){
        Write-Host "Welcome to MSS IT ASSET MANAGMENT"
        Write-Host "Portal Locations:"
        Write-Host "
                Computer Ass         (1)
                New Ass User         (2)
                Edit Laptop List     (3)
                Stop                 (4)"
        $choice = Read-Host "Please Select 1,2,3, or stop:"
        Switch($choice)
        {
         1{$ASSagain = 0;$ie = New-Webpage  -page  $MainASS ;BREAK}
         2{$ASSagain = 0;New-Ass -Site( New-Webpage  -page  $NewASS ) -choice $choice ;BREAK} # For All New Users
         3{$ASSagain = 0;Laptop-List;BREAK} # Edit Internal Laptop List
         Default {$ASSagain = 1; Break}
        }
    }
}
Function New-Ass{
Param([Parameter(Mandatory=$TRUE)]$site, [int]$choice)
        #for each new user
       foreach($_ in GETSQL-NEWHIRE)
       {
        #For laptop choice on a new asset
        If($_.laptop -eq $true ){$CompType = "Laptop"}
        else{$CompType = "Desktop"}
        # Gets Ass Page and the next few lines get details 
        $newID = ((GETSQL-INV) +1).tostring()
        $SN = Read-Host -prompt "enter serial / service tag" 
        $OsVersion = Read-Host -prompt "0 = win7 , 1 = win10"
        if($OSversion -eq 0){$os = "Windows 7"} else{ $os = "Windows 10"}
        #Puts all those details into a name/value array 
        #I should probably make $NewID some function that returns the input.  that might clean up the above
        $SearchByIDArray =@(
        [pscustomobject]@{  name = "MSSID"         ; value = $newID};
        [pscustomobject]@{  name = "Type"          ; value = $CompType};
        [pscustomobject]@{  name = "ServiceTag"    ; value = $sn};
        [pscustomobject]@{  name = "Department"    ; value = $_.Division};
        [pscustomobject]@{  name = "DateIssued"    ; value = Get-Date -UFormat %m\%d\%Y};
        [pscustomobject]@{  name = "DatePurchased" ; value = Get-Date -UFormat %m\%d\%Y})
        $SearchByNameArray =@(
        [pscustomobject] @{ name  = "Brand"         ; value = "Dell" }
        [pscustomobject] @{ name  = "Model"         ; value =  read-host -Prompt "enter model"}
        [pscustomobject] @{ name  = "SN"            ; value = $sn }
        [pscustomobject] @{ name  = "IssuedTo"      ; value = $_.FULLNAME}
        [pscustomobject] @{ name  = "OSVersion"     ; value = $os }
        [pscustomobject] @{ name  = "OfficeVersion" ; value = "Office 365"}
        [pscustomobject] @{ name  = "AdobeVersion"  ; value = "Adobe Reader 9"}
        [pscustomobject] @{ name  = "AutoDesk"      ; value = "DWG TruView" })
        #Foreach name in the array it gets by that ID and assigns it the appropriate value
        ForEach($_ in $SearchByIDArray){$site.document.getelementbyID($_.name).value = $_.value}
        ForEach($_ in $SearchByNameArray){$site.document.getelementsByName($_.name)[0].value = $_.value}
       }
}
# A Stupid Funciton
Function NEW-HIRE{
Param([string]$site)
$doagain = 1
    $ie = New-Webpage -page $site 
    while($ie.busy) {sleep 3} 
    $ie.Document.IHTMLDocument3_getElementById("UID").value = $crd2s.User
    $ie.Document.IHTMLDocument3_getElementById("passwd").value = $crd2s.Pass
    while($ie.busy) {sleep 3} 
    $ie.Document.IHTMLDocument3_getElementById("button").click()
    While($doagain -eq 0){

}
}






#Actual running code
#MSS Helpdesk Automation
#Get where
$OLDLaptopList ='[System.Collections.ArrayList] $Laptops ='; for($i=0; $i -lt $laptops.count; $i++)
{ if($i -eq $laptops.count -1) 
     {$OLDlaptoplist += ('"'+ $laptops[$i] +'"')}
  else{$OLDlaptoplist += ('"'+ $laptops[$i]  +'",')}}
$PSScriptRoot
$vis = $null
$Choice = ""
$doagain = 0
$crds =@([pscustomObject] @{
        User   =  "itgroup" 
        Pass   =  "helpme"})
$crd2s =@([pscustomObject] @{
        User   =  "John.White@msssolutions.com" 
        Pass   =  "Tuck1001"})
While($doagain -eq 0){
    Write-Host "Welcome to MSS Helpdesk Automation"
    Write-Host "Portal Locations: 
                HelpDesk Admin    (1)
                Asset Management  (2)
                New Hire          (3)
                Stop              (4) #does not function yet"
    $choice = Read-Host "Please Select 1,2,3,or stop:"
    Switch($choice)
       {
        1{$doagain = 0;New-Ticket($crds) -site  $HelpPortal  ;BREAK}
        2{$doagain = 0;Ass-Man($crds)    -site  $AssPortal  ;BREAK}
        3{$doagain = 0;NEW-HIRE($crd2s)  -site  $HirePortal ;BREAK}
        Default{$doagain = 1; Break}
       }
}


