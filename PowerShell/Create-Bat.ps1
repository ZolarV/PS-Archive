# creates a bat to set shared drive
# input string, output none
Function Create-Bat
{
param([string]$username)
	# Get the Drive letter and share
	$Drive_Letter = Read-host -prompt "Drive letter: "
	$Drive_Letter = $Drive_letter + ":"
	$Share = Read-Host -prompt "Enter UNC path: "
	$Share = '"' + $Share + '"'
	#Creates the batch file
	new-item -path $home\desktop\$username.bat -type file
	add-content $home\desktop\$username.bat "net use   $Drive_letter  $Share /persistent:yes " 
	add-content $home\desktop\$username.bat "pause"
}