$import = Import-CSV C:\Users\MCurtis\Desktop\Projects\testCSV.csv
$Temporary =@()
foreach($_  in $import) 
{

    if($_.Name -eq $Temporary[-1].Name)
    {
        if($Temporary[-1].Phone2 -eq " ")
        { $Temporary[-1].Phone2 =$_.phone }
        else
        { $Temporary[-1].Phone3 =$_.phone }
    }
    else{
    $Temporary = $Temporary + @([pscustomObject] @{
        Name   = $_.name 
        Addr   = $_.Addr 
        County = $_.County 
        City   = $_.City
        State  = $_.State
        Num1   = $_.Num1 
        Phone  = $_.Phone
        Phone2 = " "
        Phone3 = " " 
        Var1   = $_.Var1
        DOB    = $_.DOB
        Num2   = $_.Num2
       })
    }
}
$Temporary | Export-Csv C:\Users\MCurtis\Desktop\Projects\NewList.CSV -NoTypeInformation