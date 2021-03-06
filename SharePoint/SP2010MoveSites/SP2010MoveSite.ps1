## SharePoint Server 2010: PowerShell Move Sites Script With GUI Functionality
## Overview: The Script essentially uses the Export-SPWeb; New-SPWeb; and Import-SPWeb Commandlets with .cmp files
## Resource: http://movesites.codeplex.com
## Usage: Run './SP2010MoveSite.ps1' and complete the GUI box parameters. Relative path on 'new Site URL' seems to only work.
## File Location: .cmp files and import / export logs are written to "C:\SundownSolutions"
#----------------------------------------------------------------------------------------------------Adds SharePoint Module
Add-PsSnapin Microsoft.SharePoint.PowerShell

#----------------------------------------------------------------------------------------------------Dialog Box 1 - Site to be exported
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Site to be Moved"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(110,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "Next"
$OKButton.Add_Click({$SiteToExport=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,10) 
$objLabel.Size = New-Object System.Drawing.Size(280,40) 
$objLabel.Text = "Please enter the name of the site you wish to EXPORT"
$objForm.Controls.Add($objLabel) 

$objLabel1 = New-Object System.Windows.Forms.Label
$objLabel1.Location = New-Object System.Drawing.Size(10,80) 
$objLabel1.Size = New-Object System.Drawing.Size(280,40) 
$objLabel1.Text = "Please ensure you use the full name for the site less the welcome page name i.e. http://export/site/"
$objForm.Controls.Add($objLabel1) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,50) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})

[void] $objForm.ShowDialog()

#----------------------------------------------------------------------------------------------------Opens the Browser link to SP2010 blog that lists the Site Templates and Codes

$ie = new-object -comobject "InternetExplorer.Application"
$ie.visible = $true
$ie.navigate("http://www.sp2010blog.com/Blog/Lists/Posts/Post.aspx?ID=48")

#----------------------------------------------------------------------------------------------------User selects origional site template

[array]$DropDownArray = "STS#0","STS#1","STS#2","MPS#0","MPS#1","MPS#2","MPS#3","MPS#4","WIKI#0","BLOG#0","SGS#0","TENANTADMIN#0","ACCSRV#0","ACCSRV#1","ACCSRV#3","ACCSRV#4","ACCSRV#6","ACCSRV#5","BDR#0","OFFILE#0","OFFILE#1","OSRV#0","PowerPivot#0","PowerPointBroadcast#0","PPSMASite#0","BICenterSite#0","SPS#0","SPSPERS#0","SPSMSITE#0","SPSTOC#0","SPSTOPIC#0","SPSNEWS#0","CMSPUBLISHING#0","BLANKINTERNET#0","BLANKINTERNET#1","BLANKINTERNET#2","SPSNHOME#0","SPSSITES#0","SPSCOMMU#0","SPSREPORTCENTER#0","SPSPORTAL#0","SRCHCEN#0","PROFILES#0","BLANKINTERNETCONTAINER#0","SPSMSITEHOST#0","ENTERWIKI#0","SRCHCENTERLITE#0","SRCHCENTERLITE#1","SRCHCENTERFAST#0","visprus#0"

# This Function Returns the Selected Value and Closes the Form

function Return-DropDown {

	$Choice = $DropDown.SelectedItem.ToString()
	$Form.Close()
	Write-Host $Choice

}

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$Form = New-Object System.Windows.Forms.Form

$Form.width = 380
$Form.height = 200
$Form.Text = ”Select the Origional Site Template”
$Form.StartPosition = "CenterScreen"

$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(170,10)
$DropDown.Size = new-object System.Drawing.Size(190,30)

ForEach ($Item in $DropDownArray) {
	$DropDown.Items.Add($Item)
}

$Form.Controls.Add($DropDown)

$DropDownLabel = new-object System.Windows.Forms.Label
$DropDownLabel.Location = new-object System.Drawing.Size(15,13)
$DropDownLabel.size = new-object System.Drawing.Size(150,20)
$DropDownLabel.Text = "Origional Site Template"
$Form.Controls.Add($DropDownLabel)

$Button = new-object System.Windows.Forms.Button
$Button.Location = new-object System.Drawing.Size(210,50)
$Button.Size = new-object System.Drawing.Size(100,20)
$Button.Text = "Select Template"
$Button.Add_Click({Return-DropDown})
$form.Controls.Add($Button)

$DropDownExplination = new-object System.Windows.Forms.Label
$DropDownExplination.Location = new-object System.Drawing.Size(10,90)
$DropDownExplination.size = new-object System.Drawing.Size(380,60)
$DropDownExplination.Text = "Please sleect the site template that was used to create the ORIGIONAL site that you want to export - to view a list of site templates and id's click here"
$Form.Controls.Add($DropDownExplination)

$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()

[string] $DropDown = [System.Convert]::ToString($TemplateName)

#----------------------------------------------------------------------------------------------------Creates the storage Folder

[IO.Directory]::CreateDirectory("c:\SundownSolutions")

#----------------------------------------------------------------------------------------------------Exports the Web Site to its own date and time stamped file
$Date = Get-Date
$Filename="ExportedSite{0:d2}{1:d2}{2:d2}-{3:d2}{4:d2}.cmp" -f $date.day,$date.month,$date.year,$date.hour,$date.minute
$Filename2 = "c:\SundownSolutions\" + $Filename

Export-SPWeb $SiteToExport –Path $FileName2

#----------------------------------------------------------------------------------------------------Dialog Box 2 - Import Location

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Location to be moved to"
$objForm.Size = New-Object System.Drawing.Size(300,300) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(110,200)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "Start Import"
$OKButton.Add_Click({$ImportLocation=$objTextBox.Text;$objForm.Close()})
$OKButton.Add_Click({$SiteTitle=$objTextBoxTitle.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,10) 
$objLabel.Size = New-Object System.Drawing.Size(280,40) 
$objLabel.Text = "Please enter the top level location to move your site to (i.e.http://export/)"
$objForm.Controls.Add($objLabel) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,50) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objLabelTitle = New-Object System.Windows.Forms.Label
$objLabelTitle.Location = New-Object System.Drawing.Size(10,90) 
$objLabelTitle.Size = New-Object System.Drawing.Size(280,40) 
$objLabelTitle.Text = "Please enter the new Site URL i.e. New Site (this will create a site at http://export/New Site/)"
$objForm.Controls.Add($objLabelTitle) 

$objTextBoxTitle = New-Object System.Windows.Forms.TextBox 
$objTextBoxTitle.Location = New-Object System.Drawing.Size(10,130) 
$objTextBoxTitle.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBoxTitle) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})

[void] $objForm.ShowDialog()

#----------------------------------------------------------------------------------------------------Create new site based on Template and name chosen

New-SPWeb $importLocation$SiteTitle -Template $TemplateName -Name $SiteTitle

#----------------------------------------------------------------------------------------------------Imports the web site

Import-SPWeb $ImportLocation$SiteTitle –Path $FileName2 –UpdateVersions Overwrite

#----------------------------------------------------------------------------------------------------End Of Operation Menu

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Congratulations - Site Move Complete"
$objForm.Size = New-Object System.Drawing.Size(280,170) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
    
$objLabelTitle = New-Object System.Windows.Forms.Label
$objLabelTitle.Location = New-Object System.Drawing.Size(10,10) 
$objLabelTitle.Size = New-Object System.Drawing.Size(280,40) 
$objLabelTitle.Text = "Congratulations - Your Site Move is now complete!"
$objForm.Controls.Add($objLabelTitle) 

$objLabelTitle = New-Object System.Windows.Forms.Label
$objLabelTitle.Location = New-Object System.Drawing.Size(10,50) 
$objLabelTitle.Size = New-Object System.Drawing.Size(280,40) 
$objLabelTitle.Text = "All files created for this operation are stored here: c:\SundownSolutions\ - If you have finished with the export files please feel free to delete them"
$objForm.Controls.Add($objLabelTitle) 


$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(115,100)
$OKButton.Size = New-Object System.Drawing.Size(50,25)
$OKButton.Text = "OK"
$OKButton.Add_Click({$End=$objTextBox.Text;$objForm.Close()})
$OKButton.Add_Click({$Endok=$objTextBoxTitle.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

[void] $objForm.ShowDialog()

#----------------------------------------------------------------------------------------------------Deletes all files from the folder excvept the log files (to ensure large .cmp files arn't left on the C: Drive!)

Remove-Item c:\sundownsolutions\* -exclude *.txt,*.log

#----------------------------------------------------------------------------------------------------Dispose all objects in the script - cleaning up :)

function Dispose-All {
  Get-Variable -exclude Runspace |
       Where-Object {
           $_.Value -is [System.IDisposable]
       } |
       Foreach-Object {
           $_.Value.Dispose()
           Remove-Variable $_.Name
       }
}

#----------------------------------------------------------------------------------------------------Notes Section

#Variables that are used in this script
#$SiteToExport
#$Template
#$web.WebTemplate
#$ImportLocation
#$SiteTitle
#$DropDown - Used to select the template (before converted to string)
#$TemplateName - After string copnversion
#Date
#Filename
#Filename2
