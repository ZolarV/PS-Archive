#Gets Credentials and returns as Array
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