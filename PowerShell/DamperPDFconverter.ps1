# Script Created by Michael Curtis 
# 2/27/2018
# Description:  This script parses through the PDF damper reports and extracts the information and the images.
# It outputs batch damper data to CSV file for importing into damper reports
# It also renames each damper image as Damper report it originated in.
# Parse PDF data.  to use download ITextsharp 
# Download http://sourceforge.net/projects/itextsharp/
# USING http://www.xpdfreader.com/download.html
# Windows 32/64-bit XPDF TOOLS install
 # Prelim Code and functions
 $counter = 0
 $temporary = @()

 #File Installs
 $ItextURL = "\\FS05FILE\Installs\PowerShellINstalls\ITEXTSHARP.zip"
 $PDFtoolURL = "\\FS05FILE\Installs\PowerShellINstalls\XPDFTOOLS.zip"
 #PATHS
 $ItextPATH = "\\FS05FILE\Damper Reports\RequiredInstalls\itextsharp.dll"
 $PDFimgPATH = "\\FS05FILE\Damper Reports\RequiredInstalls\xpdf-tools-win-4.00\bin32\pdfimages.exe"
 $ImagePATH = "\\FS05FILE\Damper Reports\Images"
 $DIR = "\\fs05file\Damper Reports"
 #Check and Get files
 if(!(Test-Path ("\\FS05FILE\Damper Reports\Itextsharp.zip"))){
 Start-BitsTransfer -Source "\\FS05FILE\Installs\PowerShellINstalls\*.*" -Destination "\\FS05FILE\Damper Reports\"
 }
 # Check for required installs, if not exist, unzip them in the required directories
 if(!(Test-Path ("\\FS05FILE\Damper Reports\RequiredINstalls")))
 {  
 # Creates required directory if it does not exist
 New-Item -Path $DIR -Name "RequiredINstalls" -ItemType dir
 $DIR2 = $DIR + "\RequiredINstalls"
 }
 if(!(Test-Path ("\\FS05FILE\Damper Reports\Images")))
 {  
 # Creates required Image Directory if it does not exist
 New-Item -Path $DIR -Name "Images" -ItemType dir
 $ImagePath = $DIR + "\Images"
 }
 # Checks if file exists, if it doesnt it extracts it from the appropriate zip
 if(!(Test-Path("\\FS05FILE\Damper Reports\RequiredInstalls\itextsharp.dll")))
 {  
 TRY {
 (Get-ChildItem -Path "\\FS05FILE\Damper Reports\" -Filter *.zip)| where-object {$_.name -Clike "itextsharp.zip"}  | foreach-object {[io.compression.zipfile]::ExtractToDirectory($_.FullName, "\\FS05FILE\Damper Reports\RequiredINstalls" ) }
 (Get-ChildItem -Path "\\FS05FILE\Damper Reports\RequiredINstalls" -Filter *.zip)  | where-object {$_.name -Clike "itextsharp-dll-core.zip"} | foreach-object {[io.compression.zipfile]::ExtractToDirectory($_.FullName, "\\FS05FILE\Damper Reports\RequiredINstalls" ) }
 $ItextPATH = "\\FS05FILE\Damper Reports\RequiredInstalls\itextsharp.dll" 
 }
 CATCH {Write-host "File Already Exists"}
 }
if(!(Test-Path("\\FS05FILE\Damper Reports\RequiredInstalls\xpdf-tools-win-4.00\bin32\pdfimages.exe")))
{
TRY {
(Get-ChildItem -Path "\\FS05FILE\Damper Reports\" -Filter *.zip) | where-object {$_.name -Clike "XPDFTOOLS.ZIP"}  | foreach-object {[io.compression.zipfile]::ExtractToDirectory($_.FullName, "\\FS05FILE\Damper Reports\RequiredINstalls" ) }
$PDFimgPATH = "\\FS05FILE\Damper Reports\RequiredInstalls\xpdf-tools-win-4.00\bin32\pdfimages.exe"
}
CATCH{Write-host "File Already Exists"}
}  

 
# Add type for .DLL usage in PDF parsing
 Add-Type -Path $ItextPATH
# Function for extracting Images
 function Extract-PDFImages($pdfPath,$imgFolder,$imgPrefix){
	if (!(Test-Path $imgFolder)){New-Item $imgFolder -ItemType Dir | Out-Null}
	$root="$imgFolder\$imgPrefix"
	& '\\FS05FILE\Damper Reports\RequiredInstalls\xpdf-tools-win-4.00\bin32\pdfimages.exe' "-j" "$pdfPath" "$root" 
}
#Gets current location for script to get Technician name from Folder name
$CurrentLocation = [environment]::CurrentDirectory
$CurrentLocation = $CurrentLocation.remove(0,$dir.length +1  )
$technician = $CurrentLocation
#For each PDF in Technicans folder
$list = (Get-ChildItem -Filter *.pdf)
 foreach($_ in $list)
 {
    $counter = 0
    $reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $_.name
    #Clear variables
    $floor = ""; $Location = "";$Damper_Num = ""; $Asset_Num = ""; $pass= ""; $Damper_type = "";$Date = ""; $date_sub = ""


     for ($page = 1; $page -le $reader.NumberOfPages; $page++)
    {
      # extract a page and split it into lines
     $text = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader,$page).Split([char]0x000A)  
     foreach ($line in $text)
    {
    # line formatting for easier string recognition
      $line = $line.ToUpper()
      # Checks each line for key words,  extracts contents past key words
     if($line.contains("PASS")){$Pass= $line.Substring(4,($line.Length -4 ))  }
     if($line.contains("FLOOR")) {$floor = $line.Substring(5,($line.Length -5 )) }
     if($line.contains("ASSET#")) {$Asset_Num = $line.Substring(6,($line.Length -6 )) }
     if($line.contains("DAMPER#")) {$Damper_Num =$line.Substring(7,($line.Length -7 )) }
     if($line.contains("DAMPER_TYPE")-or $line.contains("DAMPER TYPE")) {$Damper_type = $line.Substring(11,($line.Length -11 )) }
     if($line.contains("DATE / TIME")) {$Date = $line.Substring(12,($line.Length -12 )) }
     if($line.contains("DAMPER_LOCATION") -OR $line.Contains("DAMPER LOCATION")) {$Location = $line.Substring(15,($line.Length -15 )) }
     # IF no date exists, gets date from submission
     if($line -eq $text[$text.count - 1] -and $Date -eq "") {$date_sub = $line.Substring(0,12)}
     }
    }
        # Inputs Data into new CSV object
        $Temporary = $Temporary + @([pscustomObject] @{
                Date_Time   = $Date
                Damper   = $Damper_Num
                Asset = $Asset_Num
                Floor  = $floor
                Location  = $Location
                Type   = $Damper_type
                Pass_fail  = $pass
                Reason_For_Failure = " "
                Technician = $technician
                Submitted_Date = $date_sub
               })

               

        #Extract Images
        Extract-PDFImages $_.FullName $ImagePath "Damper $Damper_Num"
        #Clear Variables
        $img = 0
        $name = ""
        #renames Images
        (Get-ChildItem -Path $ImagePATH | Where-object $_.name -like "img") | ForEach-Object {$img++; $name = "Damper $Damper_Num $img"+".jpg";    Rename-Item -path $_.FullName -newname $name} 

 }
    
#Last step
$temporary | Export-Csv '\$technicianExport.csv ' -NoTypeInformation


# Extra code and troubleshooting code
# Extract Images
# Extract-PDFImages "C:\Users\MCurtis\desktop\Damper Project\Dampers2319.pdf" "C:\Users\MCurtis\desktop\Damper Project\test" "img"
# (Get-ChildItem -Path "C:\Users\MCurtis\desktop\Damper Project\test") | ForEach-Object {$img++; $name = "Damper $Damper_Number $img"+".jpg";    Rename-Item -path $_.FullName -newname $name} 