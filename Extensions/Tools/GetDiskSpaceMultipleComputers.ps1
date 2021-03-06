function Get-DiskSpace
{
function OnApplicationLoad {
return $true
}

function OnApplicationExit {
#Note: This function runs after the form is closed
#TODO: Add custom code to clean up and unload snapins when the application exits
}

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-SystemInformation_pff {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
     [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
    #get-pssnapin -Registered -ErrorAction silentlycontinue

	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object System.Windows.Forms.Form
	$btnRefresh = New-Object System.Windows.Forms.Button
   
    $btnsearch = New-Object System.Windows.Forms.Button
    $btngetdata=New-Object System.Windows.Forms.Button
	$rtbPerfData = New-Object System.Windows.Forms.RichTextBox
	#$pictureBox1 = New-Object System.Windows.Forms.PictureBox
    $lblServicePack = New-Object System.Windows.Forms.Label
    $lblDBName= New-Object System.Windows.Forms.Label
	$lblOS = New-Object System.Windows.Forms.Label
    $lblExpire = New-Object System.Windows.Forms.Label
	$statusBar1 = New-Object System.Windows.Forms.StatusBar
	$btnClose = New-Object System.Windows.Forms.Button
	#$comboServers = New-Object System.Windows.Forms.ComboBox
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    $txtComputerName1 = New-Object System.Windows.Forms.TextBox
    $txtComputerName2 = New-Object System.Windows.Forms.TextBox
    $datagridviewResults = New-Object System.Windows.Forms.DataGridview
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
    $labelSubject = New-Object 'System.Windows.Forms.Label'
	$labelFrom = New-Object 'System.Windows.Forms.Label'
	$labelSMTPServer = New-Object 'System.Windows.Forms.Label'
    $labelTo = New-Object 'System.Windows.Forms.Label'
    $txtSubject = New-Object System.Windows.Forms.TextBox
    $txtFrom = New-Object System.Windows.Forms.TextBox
    $txtSMTPServer = New-Object System.Windows.Forms.TextBox
    $txtTo = New-Object System.Windows.Forms.TextBox
    $buttonEMailOutput = New-Object System.Windows.Forms.Button
    

   #$dataGrid1 = new-object System.windows.forms.DataGridView


	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
function Sort-ListViewColumn 
{
	<#
	.SYNOPSIS
		Sort the ListView's item using the specified column.

	.DESCRIPTION
		Sort the ListView's item using the specified column.
		This function uses Add-Type to define a class that sort the items.
		The ListView's Tag property is used to keep track of the sorting.

	.PARAMETER ListView
		The ListView control to sort.

	.PARAMETER ColumnIndex
		The index of the column to use for sorting.
		
	.PARAMETER  SortOrder
		The direction to sort the items. If not specified or set to None, it will toggle.
	
	.EXAMPLE
		Sort-ListViewColumn -ListView $listview1 -ColumnIndex 0
#>
	param(	
			[ValidateNotNull()]
			[Parameter(Mandatory=$true)]
			[System.Windows.Forms.ListView]$ListView,
			[Parameter(Mandatory=$true)]
			[int]$ColumnIndex,
			[System.Windows.Forms.SortOrder]$SortOrder = 'None')
	
	if(($ListView.Items.Count -eq 0) -or ($ColumnIndex -lt 0) -or ($ColumnIndex -ge $ListView.Columns.Count))
	{
		return;
	}
	
	#region Define ListViewItemComparer
		try{
		$local:type = [ListViewItemComparer]
	}
	catch{
	Add-Type -ReferencedAssemblies ('System.Windows.Forms') -TypeDefinition  @" 
	using System;
	using System.Windows.Forms;
	using System.Collections;
	public class ListViewItemComparer : IComparer
	{
	    public int column;
	    public SortOrder sortOrder;
	    public ListViewItemComparer()
	    {
	        column = 0;
			sortOrder = SortOrder.Ascending;
	    }
	    public ListViewItemComparer(int column, SortOrder sort)
	    {
	        this.column = column;
			sortOrder = sort;
	    }
	    public int Compare(object x, object y)
	    {
			if(column >= ((ListViewItem)x).SubItems.Count)
				return  sortOrder == SortOrder.Ascending ? -1 : 1;
		
			if(column >= ((ListViewItem)y).SubItems.Count)
				return sortOrder == SortOrder.Ascending ? 1 : -1;
		
			if(sortOrder == SortOrder.Ascending)
	        	return String.Compare(((ListViewItem)x).SubItems[column].Text, ((ListViewItem)y).SubItems[column].Text);
			else
				return String.Compare(((ListViewItem)y).SubItems[column].Text, ((ListViewItem)x).SubItems[column].Text);
	    }
	}
"@  | Out-Null
	}
	#endregion
	
	if($ListView.Tag -is [ListViewItemComparer])
	{
		#Toggle the Sort Order
		if($SortOrder -eq [System.Windows.Forms.SortOrder]::None)
		{
			if($ListView.Tag.column -eq $ColumnIndex -and $ListView.Tag.sortOrder -eq 'Ascending')
			{
				$ListView.Tag.sortOrder = 'Descending'
			}
			else
			{
				$ListView.Tag.sortOrder = 'Ascending'
			}
		}
		else
		{
			$ListView.Tag.sortOrder = $SortOrder
		}
		
		$ListView.Tag.column = $ColumnIndex
		$ListView.Sort()#Sort the items
	}
	else
	{
		if($Sort -eq [System.Windows.Forms.SortOrder]::None)
		{
			$Sort = [System.Windows.Forms.SortOrder]::Ascending	
		}
		
		#Set to Tag because for some reason in PowerShell ListViewItemSorter prop returns null
		$ListView.Tag = New-Object ListViewItemComparer ($ColumnIndex, $SortOrder) 
		$ListView.ListViewItemSorter = $ListView.Tag #Automatically sorts
	}
}


function Add-ListViewItem
{
<#
	.SYNOPSIS
		Adds the item(s) to the ListView and stores the object in the ListViewItem's Tag property.

	.DESCRIPTION
		Adds the item(s) to the ListView and stores the object in the ListViewItem's Tag property.

	.PARAMETER ListView
		The ListView control to add the items to.

	.PARAMETER Items
		The object or objects you wish to load into the ListView's Items collection.
		
	.PARAMETER  ImageIndex
		The index of a predefined image in the ListView's ImageList.
	
	.PARAMETER  SubItems
		List of strings to add as Subitems.
	
	.PARAMETER Group
		The group to place the item(s) in.
	
	.PARAMETER Clear
		This switch clears the ListView's Items before adding the new item(s).
	
	.EXAMPLE
		Add-ListViewItem -ListView $listview1 -Items "Test" -Group $listview1.Groups[0] -ImageIndex 0 -SubItems "Installed"
#>
	
	Param( 
	[ValidateNotNull()]
	[Parameter(Mandatory=$true)]
	[System.Windows.Forms.ListView]$ListView,
	[ValidateNotNull()]
	[Parameter(Mandatory=$true)]
	$Items,
	[int]$ImageIndex = -1,
	[string[]]$SubItems,
	[System.Windows.Forms.ListViewGroup]$Group,
	[switch]$Clear)
	
	if($Clear)
	{
		$ListView.Items.Clear();
	}
	
	if($Items -is [Array])
	{
		$ListView.BeginUpdate()
		foreach ($item in $Items)
		{		
			$listitem  = $ListView.Items.Add($item.ToString(), $ImageIndex)
			#Store the object in the Tag
			$listitem.Tag = $item
			
			if($SubItems -ne $null)
			{
				$listitem.SubItems.AddRange($SubItems)
			}
			
			if($Group -ne $null)
			{
				$listitem.Group = $Group
			}
		}
		$ListView.EndUpdate()
	}
	else
	{
		#Add a new item to the ListView
		$listitem  = $ListView.Items.Add($Items.ToString(), $ImageIndex)
		#Store the object in the Tag
		$listitem.Tag = $Items
		
		if($SubItems -ne $null)
		{
			$listitem.SubItems.AddRange($SubItems)
		}
		
		if($Group -ne $null)
		{
			$listitem.Group = $Group
		}
	}
}


function Load-DataGridView
{
	<#
	.SYNOPSIS
		This functions helps you load items into a DataGridView.

	.DESCRIPTION
		Use this function to dynamically load items into the DataGridView control.

	.PARAMETER  DataGridView
		The ComboBox control you want to add items to.

	.PARAMETER  Item
		The object or objects you wish to load into the ComboBox's items collection.
	
	.PARAMETER  DataMember
		Sets the name of the list or table in the data source for which the DataGridView is displaying data.

	#>
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		$Item,
	    [Parameter(Mandatory=$false)]
		[string]$DataMember
	)
	$DataGridView.SuspendLayout()
	$DataGridView.DataMember = $DataMember
	
	if ($Item -is [System.ComponentModel.IListSource]`
	-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView] )
	{
		$DataGridView.DataSource = $Item
	}
	else
	{
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}
		else
		{	
			$array.Add($Item)	
		}
		$DataGridView.DataSource = $array
	}
	
	$DataGridView.ResumeLayout()
}

function Convert-ToDataTable
{
	<#
		.SYNOPSIS
			Converts objects into a DataTable.
	
		.DESCRIPTION
			Converts objects into a DataTable, which are used for DataBinding.
	
		.PARAMETER  InputObject
			The input to convert into a DataTable.
	
		.PARAMETER  Table
			The DataTable you wish to load the input into.
	
		.PARAMETER RetainColumns
			This switch tells the function to keep the DataTable's existing columns.
		
		.PARAMETER FilterWMIProperties
			This switch removes WMI properties that start with an underline.
	
		.EXAMPLE
			Convert-ToDataTable -InputObject (Get-Process) -Table $DataTable
	#>
	
	param(
	$InputObject, 
	[ValidateNotNull()]
	[System.Data.DataTable]$Table,
	[switch]$RetainColumns,
	[switch]$FilterWMIProperties)
	
	if($InputObject -is [System.Data.DataTable])
	{
		$Table = $InputObject
		return
	}
	
	if(-not $RetainColumns -or $Table.Columns.Count -eq 0)
	{
		#Clear out the Table Contents
		$Table.Clear()

		if($InputObject -eq $null){ return } #Empty Data
		
		$object = $null
		#find the first non null value
		foreach($item in $InputObject)
		{
			if($item -ne $null)
			{
				$object = $item
				break	
			}
		}

		if($object -eq $null) { return } #All null then empty
		
		#Get all the properties in order to create the columns
		$properties = Get-Member -MemberType 'Properties' -InputObject $object
		foreach ($prop in $properties)
		{
			if(-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__'))#filter out WMI properties
			{
				#Get the type from the Definition string
				$index = $prop.Definition.IndexOf(' ')
				$type = $null
				if($index -ne -1)
				{
					$typeName = $prop.Definition.SubString(0, $index)
					try{ $type = [System.Type]::GetType($typeName) } catch {}
				}

				if($type -ne $null -and [System.Type]::GetTypeCode($type) -ne 'Object')
				{
	      			[void]$table.Columns.Add($prop.Name, $type) 
				}
				else #Type info not found
				{ 
					[void]$table.Columns.Add($prop.Name) 	
				}
			}
	    }
	}
	else
	{
		$Table.Rows.Clear()	
	}
	
	$count = $table.Columns.Count
	foreach($item in $InputObject)
	{
		$row = $table.NewRow()
		
		for ($i = 0; $i -lt $count;$i++)
    	{
			$column = $table.Columns[$i]
			$prop = $column.ColumnName	
			
			$value = Invoke-Expression ('$item.{0}' -f $prop)
			if($value -ne $null)
			{
				$row[$i] = $value
			}
		}
		
		[void]$table.Rows.Add($row)
	}
}
#endregion

#region Search Function
function SearchGrid()
{
	$RowIndex = 0
	$ColumnIndex = 0
	$seachString = $txtComputerName2.Text
	
	if($seachString -eq "")
	{
		return
	}
	
	if($datagridviewResults.SelectedCells.Count -ne 0)
	{
		$startCell = $datagridviewResults.SelectedCells[0];
		$RowIndex = $startCell.RowIndex
		$ColumnIndex = $startCell.ColumnIndex + 1
	}
	
	$columnCount = $datagridviewResults.ColumnCount
	$rowCount = $datagridviewResults.RowCount
	for(;$RowIndex -lt $rowCount; $RowIndex++)
	{
		$Row = $datagridviewResults.Rows[$RowIndex]
		
		for(;$ColumnIndex -lt $columnCount; $ColumnIndex++)
		{
			$cell = $Row.Cells[$ColumnIndex]
			
			if($cell.Value -ne $null -and $cell.Value.ToString().IndexOf($seachString, [StringComparison]::OrdinalIgnoreCase) -ne -1)
			{
				$datagridviewResults.CurrentCell = $cell
				return
			}
		}
		
		$ColumnIndex = 0
	}
	
	$datagridviewResults.CurrentCell = $null
	[void][System.Windows.Forms.MessageBox]::Show("The search has reached the end of the grid.","String not Found")
	
}
#endregion

Function Get-DiskSpaceReport
{
param([String]$list,[string]$SMTPMail,[String]$To,[String]$From
)


$freeSpaceFileName = "C:\FreeSpace.htm"


$warning = 15
$critical = 10

New-Item -ItemType file $freeSpaceFileName -Force

# Getting the freespace info using WMI
#Get-WmiObject win32_logicaldisk  | Where-Object {$_.drivetype -eq 3 -OR $_.drivetype -eq 2 } | format-table DeviceID, VolumeName,status,Size,FreeSpace | Out-File FreeSpace.txt
# Function to write the HTML Header to the file
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('yyyy/MM/dd')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>DiskSpace Report</title>'
add-content $fileName '<STYLE TYPE="text/css">'
add-content $fileName  "<!--"
add-content $fileName  "td {"
add-content $fileName  "font-family: Tahoma;"
add-content $fileName  "font-size: 11px;"
add-content $fileName  "border-top: 1px solid #999999;"
add-content $fileName  "border-right: 1px solid #999999;"
add-content $fileName  "border-bottom: 1px solid #999999;"
add-content $fileName  "border-left: 1px solid #999999;"
add-content $fileName  "padding-top: 0px;"
add-content $fileName  "padding-right: 0px;"
add-content $fileName  "padding-bottom: 0px;"
add-content $fileName  "padding-left: 0px;"
add-content $fileName  "}"
add-content $fileName  "body {"
add-content $fileName  "margin-left: 5px;"
add-content $fileName  "margin-top: 5px;"
add-content $fileName  "margin-right: 0px;"
add-content $fileName  "margin-bottom: 10px;"
add-content $fileName  ""
add-content $fileName  "table {"
add-content $fileName  "border: thin solid #000000;"
add-content $fileName  "}"
add-content $fileName  "-->"
add-content $fileName  "</style>"
Add-Content $fileName "</head>"
Add-Content $fileName "<body>"

add-content $fileName  "<table width='100%'>"
add-content $fileName  "<tr bgcolor='#CCCCCC'>"
add-content $fileName  "<td colspan='7' height='25' align='center'>"
add-content $fileName  "<font face='tahoma' color='#003399' size='4'><strong>DiskSpace Report - $date</strong></font>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"
add-content $fileName  "</table>"

}

# Function to write the HTML Header to the file
Function writeTableHeader
{
param($fileName)

Add-Content $fileName "<tr bgcolor=#CCCCCC>"
Add-Content $fileName "<td width='10%' align='center'>Drive</td>"
Add-Content $fileName "<td width= 10%' align='center'>Drive Label</td>"
Add-Content $fileName "<td width='10%' align='center'>Total Capacity(GB)</td>"
Add-Content $fileName "<td width='10%' align='center'>Used Capacity(GB)</td>"
Add-Content $fileName "<td width='10%' align='center'>Free Space(GB)</td>"
Add-Content $fileName "<td width='10%' align='center'>Freespace %</td>"
Add-Content $fileName "</tr>"
}

Function writeHtmlFooter
{
param($fileName)

Add-Content $fileName "</body>"
Add-Content $fileName "</html>"
}

Function writeDiskInfo
{
param($fileName,$devId,$volName,$frSpace,$totSpace)
$totSpace=[math]::Round(($totSpace/1073741824),2)
$frSpace=[Math]::Round(($frSpace/1073741824),2)
$usedSpace = $totSpace - $frspace
$usedSpace=[Math]::Round($usedSpace,2)
$freePercent = ($frspace/$totSpace)*100
$freePercent = [Math]::Round($freePercent,0)
if ($freePercent -gt $warning)
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td>$freePercent</td>"
Add-Content $fileName "</tr>"
}
elseif ($freePercent -le $critical)
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td bgcolor='#FF0000' align=center>$freePercent</td>"
#<td bgcolor='#FF0000' align=center>
Add-Content $fileName "</tr>"
}
else
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td bgcolor='#FBB917' align=center>$freePercent</td>"
# #FBB917
Add-Content $fileName "</tr>"
}
}


writeHtmlHeader $freeSpaceFileName


foreach ($server in Get-Content $list)
{
Add-Content $freeSpaceFileName "<table width='100%'><tbody>"
Add-Content $freeSpaceFileName "<tr bgcolor='#CCCCCC'>"
Add-Content $freeSpaceFileName "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong> $server </strong></font></td>"
Add-Content $freeSpaceFileName "</tr>"

writeTableHeader $freeSpaceFileName

$dp = Get-WmiObject win32_logicaldisk -ComputerName $server |  Where-Object {$_.drivetype -eq 3 }
foreach ($item in $dp)
{
Write-Host  $item.DeviceID  $item.VolumeName $item.FreeSpace $item.Size
writeDiskInfo $freeSpaceFileName $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size

}
  Add-Content $freeSpaceFileName "</table>" 
} 



writeHtmlFooter $freeSpaceFileName


Function sendEmail  
{ 
param($from,$to,$subject,$smtphost,$htmlFileName)  
[string]$receipients="$to"
$body = Get-Content $htmlFileName 
$body = New-Object System.Net.Mail.MailMessage $from, $receipients, $subject, $body 
$body.isBodyhtml = $true
$smtpServer = $MailServer
$smtp = new-object Net.Mail.SmtpClient($smtphost)
$validfrom= Validate-IsEmail $from
if($validfrom -eq $TRUE)
{
$validTo= Validate-IsEmail $to
if($validTo -eq $TRUE)
{
$smtp.Send($body)
write-output "Email Sent!!"

}
}
else
{
write-output "Invalid entries, Try again!!"
}
}

# Email our report out


function Validate-IsEmail ([string]$Email)
{
                
                return $Email -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$"
}


$date = ( get-date ).ToString('yyyy/MM/dd')

sendEmail -from $From -to $to -subject "Disk Space Report - $Date" -smtphost $SMTPMail -htmlfilename $freeSpaceFileName


}
function Validate-IsEmail ([string]$Email)
{
                
                return $Email -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$"
}



$FormEvent_Load={
	#TODO: Initialize Form Controls here
	
}

$buttonExit_Click={
	#TODO: Place custom script here
	$formMain.Close()
}


$buttonQuery_Click={
	#TODO: Place custom script here
#	---------------------------------
#	Sample Code to Load Grid
#	---------------------------------
#	$processes = Get-WmiObject Win32_Process -Namespace "Root\CIMV2"
#	Load-DataGridView -DataGridView $datagridviewResults -Item $processes
#	---------------------------------
#	Sample Code to Load Sortable Data
#	---------------------------------

if ($txtComputerName1.text -eq '')
{
$statusBar1.text="Select Input file or Enter Input file path...Try Again!!!"
}
else
{
#>
$Object1 = @()
foreach ($computer in (get-content $txtComputerName1.text))
{
write-host $computer
 if(Test-Connection -ComputerName $computer -Count 1 -ea 0) {  
$statusBar1.text="Getting  $computer Information...Please wait"
$D=Get-WmiObject win32_logicalDisk -ComputerName $computer -ErrorAction silentlycontinue|where {$_.DriveType -eq 3}|
select __SERVER,DeviceID,VolumeName,
@{Expression={$_.Size /1Gb -as [int]};Label=”TotalSize”},
@{Expression={($_.Size /1Gb -as [int]) – ($_.Freespace / 1Gb -as [int])};Label=”InUse”} ,
@{Expression={$_.Freespace / 1Gb -as [int]};Label=”FreeSize”},
@{Expression={(($_.Freespace /1Gb -as [int]) / ($_.Size / 1Gb -as [int]))*100};Label=”PerFreeSpace”} 
foreach($disk in $D) 
{
$Object1 += New-Object PSObject -Property @{
AppSrvName= $Disk.__Server;
Drive= $Disk.DeviceID;
DriveLabel=$Disk.VolumeName;
DriveCapacityGB=[int]$Disk.TotalSize;
DriveInUseGB=[int]$Disk.InUse;
DriveFreeGB=[int]$Disk.FreeSize;
DrivePercentFree=[int]$Disk.PerFreeSpace
} 
}


} 
 else
    {
    $statusBar1.text="Could not connect to $computer ...Try Again!!!"
    }
    
$statusBar1.text="Ready"     

}



	$table = New-Object System.Data.DataTable
	Convert-ToDataTable -InputObject ($object1) -Table $table 
	Load-DataGridView -DataGridView $datagridviewResults -Item $table
   
}
}

$buttonSearch_Click={
	#TODO: Place custom script here
	SearchGrid
}

$datagridviewResults_ColumnHeaderMouseClick=[System.Windows.Forms.DataGridViewCellMouseEventHandler]{
#Event Argument: $_ = [System.Windows.Forms.DataGridViewCellMouseEventArgs]
	if($datagridviewResults.DataSource -is [System.Data.DataTable])
	{
		$column = $datagridviewResults.Columns[$_.ColumnIndex]
		$direction = [System.ComponentModel.ListSortDirection]::Ascending
		
		if($column.HeaderCell.SortGlyphDirection -eq 'Descending')
		{
			$direction = [System.ComponentModel.ListSortDirection]::Descending
		}

		$datagridviewResults.Sort($datagridviewResults.Columns[$_.ColumnIndex], $direction)
	}
}

$listviewSort_ColumnClick=[System.Windows.Forms.ColumnClickEventHandler]{
#Event Argument: $_ = [System.Windows.Forms.ColumnClickEventArgs]
	Sort-ListViewColumn -ListView $this -ColumnIndex $_.Column
}

$listviewSort_ColumnClick2=[System.Windows.Forms.ColumnClickEventHandler]{
#Event Argument: $_ = [System.Windows.Forms.ColumnClickEventArgs]
	Sort-ListViewColumn -ListView $this -ColumnIndex $_.Column
}


 	
	$Close={
	    $form1.close()
	
	}
	

    	
	$GetData={
        $statusBar1.text=" Checking Email Entries ...Please wait"
            if ($txtfrom.Text -ne '' -and $txtto.Text -ne '' -and $txtSMTPServer.Text -ne '')
           {
           $status1=Validate-IsEmail $txtfrom.Text
           #write-host $status1
           $status2=Validate-IsEmail $txtto.Text
           #write-host $status1
           if($status1 -eq $FALSE)
           {
           [void][System.Windows.Forms.MessageBox]::Show("Check From Email Entries")
           if($status2 -eq $FALSE)
           {
           [void][System.Windows.Forms.MessageBox]::Show(" Check To Email Entries")
           }
           }
           ELSE
           {
           $statusBar1.Text="Sending Email...Please wait"
           $data=Get-DiskSpaceReport -list $txtComputerName1.text -From $txtfrom.text -To $txtTo.text -SMTPMail $txtSMTPServer.text| Out-String
           $statusBar1.Text="email sent" 
           }
           }
       
	  $statusBar1.Text="Ready" 
     }

	#>
	
	
	# --End User Generated Script--
	#----------------------------------------------
	# Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# form1
	#
    $saveFileDialog1 = New-Object System.Windows.Forms.SaveFileDialog 
	$form1.Controls.Add($btnRefresh)
    $form1.Controls.Add($btnsearch)
	#$form1.Controls.Add($rtbPerfData)
	#$form1.Controls.Add($pictureBox1)
	$form1.Controls.Add($lblServicePack)
	$form1.Controls.Add($lblOS)
    $form1.Controls.Add($lblDBName)
	$form1.Controls.Add($statusBar1)
    $form1.Controls.Add($btnClose)
    $form1.Controls.Add($txtComputerName1)
    $Form1.controls.add($Chart) 
    $Form1.controls.add($txtComputerName2)
    $Form1.controls.add($labelSubject)
    $Form1.controls.add($labelFrom)
    $Form1.controls.add($labelSMTPServer)
    $Form1.controls.add($labelTo)
    $Form1.controls.add($lblExpire)
    $Form1.controls.add($txtFrom)
    $Form1.controls.add($txtTo)
    $Form1.controls.add($txtSubject)
    $Form1.controls.add($txtSMTPServer)
    $Form1.controls.add($buttonEMailOutput)
	$form1.ClientSize = New-Object System.Drawing.Size(900,650)
	$form1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow 
	$form1.Name = "form1"
	$form1.Text = "Drive Information Tool "
	$form1.add_Load($PopulateList)
   
    
# create chart object 

    
$System_Drawing_Size = New-Object System.Drawing.Size 
$System_Drawing_Size.Width = 850 
$System_Drawing_Size.Height = 450
$datagridviewResults.Size = $System_Drawing_Size 
$datagridviewResults.DataBindings.DefaultDataSourceUpdateMode = 0 
#$datagridviewResults.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0) 
$datagridviewResults.Name = "dataGrid1" 
$datagridviewResults.DataMember = "" 
$datagridviewResults.TabIndex = 0 
$System_Drawing_Point = New-Object System.Drawing.Point 
$System_Drawing_Point.X =13 
$System_Drawing_Point.Y = 72
$datagridviewResults.Location = $System_Drawing_Point 
$Chart.visible=$FALSE
$form1.Controls.Add($datagridviewResults) 

#$datagridviewResults.CaptionText='Service Comparison'

	#
	# btnRefresh
	#
	$btnRefresh.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$btnRefresh.Enabled = $TRUE
	$btnRefresh.Location = New-Object System.Drawing.Point(500,10)
	$btnRefresh.Name = "btnRefresh"
	$btnRefresh.Size = New-Object System.Drawing.Size(72,20)
	$btnRefresh.TabIndex = 3
	$btnRefresh.Text = "GetDisk"
	$btnRefresh.UseVisualStyleBackColor = $True
	$btnRefresh.add_Click($buttonQuery_Click)
    #
    #
    #
	# btnsearch
	#
	#$btnsearch.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$btnsearch.Enabled = $TRUE
	$btnsearch.Location = New-Object System.Drawing.Point(570,35)
	$btnsearch.Name = "btnsearch"
	$btnsearch.Size = New-Object System.Drawing.Size(72,20)
	$btnsearch.TabIndex = 6
	$btnsearch.Text = "Search"
	$btnsearch.UseVisualStyleBackColor = $True
	$btnsearch.add_Click($buttonSearch_Click)
    #
  
    # btnClose
	#
    
	$btnClose.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$btngetdata.Enabled = $TRUE
    $btnClose.Location = New-Object System.Drawing.Point(573,10)
	$btnClose.Name = "btnClose"
	$btnClose.Size = New-Object System.Drawing.Size(72,20)
	$btnClose.TabIndex = 4
	$btnClose.Text = "Close"
	$btnClose.UseVisualStyleBackColor = $True
	$btnClose.add_Click($Close)
	#
    
    # lblDBName
	#
	$lblDBName.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$lblDBName.Font = New-Object System.Drawing.Font("Lucida Console",8.25,1,3,1)
	$lblDBName.Location = New-Object System.Drawing.Point(13,10)
	$lblDBName.Name = "lblDBName"
	$lblDBName.Size = New-Object System.Drawing.Size(178,23)
	$lblDBName.TabIndex = 0
	$lblDBName.Text = "Select Input file  "
	$lblDBName.Visible = $TRUE
    #
    
	#$txtComputerName1.text
    #txtComputerName1
    $txtComputerName1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtComputerName1.Location = New-Object System.Drawing.Point(200, 10)
    $txtComputerName1.Name = "txtComputerName1"
    $txtComputerName1.TabIndex = 1
    $txtComputerName1.Size = New-Object System.Drawing.Size(200,70)
    $txtComputerName1.visible=$TRUE
	#
    
    #
    # lblExpire
	#
	$lblExpire.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$lblExpire.Font = New-Object System.Drawing.Font("Lucida Console",8.25,1,3,1)
	$lblExpire.Location = New-Object System.Drawing.Point(13,35)
	$lblExpire.Name = "lblExpire"
	$lblExpire.Size = New-Object System.Drawing.Size(178,23)
	$lblExpire.TabIndex = 0
	$lblExpire.Text = "Enter the search String"
	$lblExpire.Visible = $TRUE
    #
	#$txtComputerName2.text
    #txtComputerName2
    $txtComputerName2.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtComputerName2.Location = New-Object System.Drawing.Point(200,35)
    $txtComputerName2.Name = "txtComputerName2"
    $txtComputerName2.TabIndex = 5
    $txtComputerName2.Size = New-Object System.Drawing.Size(400,70)
    $txtComputerName2.visible=$TRUE
	#
	# lblServicePack
	#
	$lblServicePack.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$lblServicePack.Font = New-Object System.Drawing.Font("Lucida Console",8.25,1,3,1)
	$lblServicePack.Location = New-Object System.Drawing.Point(13,100)
	$lblServicePack.Name = "lblServicePack"
	$lblServicePack.Size = New-Object System.Drawing.Size(278,23)
	$lblServicePack.TabIndex = 0
	$lblServicePack.Text = "ServicePack"
	$lblServicePack.Visible = $False
	#
	# lblOS
	#
	$lblOS.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$lblOS.Font = New-Object System.Drawing.Font("Lucida Console",8.25,1,3,1)
	$lblOS.Location = New-Object System.Drawing.Point(12,77)
	$lblOS.Name = "lblOS"
	$lblOS.Size = New-Object System.Drawing.Size(278,23)
	$lblOS.TabIndex = 2
	$lblOS.Text = "User Information"
	$lblOS.Visible = $False
	#
	# statusBar1
	#
	$statusBar1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$statusBar1.Location = New-Object System.Drawing.Point(0,365)
	$statusBar1.Name = "statusBar1"
	$statusBar1.Size = New-Object System.Drawing.Size(390,22)
	$statusBar1.TabIndex = 5
	$statusBar1.Text = "statusBar1"
    #
	#>
    # labelSubject
	#
	$labelSubject.Location = '350, 578'
	$labelSubject.Name = "labelSubject"
	$labelSubject.Size = '50, 19'
	#$labelSubject.TabIndex = 18
	$labelSubject.Text = "Subject"
	#
	# labelFrom
	#
	$labelFrom.Location = '17, 538'
	$labelFrom.Name = "labelFrom"
	$labelFrom.Size = '50, 19'
	$labelFrom.Text = "From"
	#
	# label1
	#
	$labelTo.Location = '17, 578'
	$labelTo.Name = "labelTo"
	$labelTo.Size = '50, 19'
	#$labelTo.TabIndex = 16
	$labelTo.Text = "To"
	#
	# labelSMTPServer
	#
	$labelSMTPServer.Location = '350, 538'
	$labelSMTPServer.Name = "labelSMTPServer"
	$labelSMTPServer.Size = '50, 19'
	#$labelSMTPServer.TabIndex = 15
	$labelSMTPServer.Text = "SMTP"
    #
    #txtSubject
    #
    $txtSubject.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtSubject.Location = New-Object System.Drawing.Point(420,578)
    $txtSubject.Name = "txtSubject"
    $txtSubject.Size = New-Object System.Drawing.Size(200,70)
    $txtSubject.visible=$TRUE
    #
    #txtFrom
    #
    $txtFrom.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtFrom.Location = New-Object System.Drawing.Point(67,538)
    $txtFrom.Name = "txtFrom"
    #$txtFrom.TabIndex = 1
    $txtFrom.Size = New-Object System.Drawing.Size(200,70)
    $txtFrom.visible=$TRUE
    
     #
    #txtSMTPServer
    #
    $txtSMTPServer.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtSMTPServer.Location = New-Object System.Drawing.Point(420,538)
    $txtSMTPServer.Name = "txtSMTPServer"
    $txtSMTPServer.Size = New-Object System.Drawing.Size(200,70)
    $txtSMTPServer.visible=$TRUE
    
        #
    #txtTo
    #
    $txtTo.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
    $txtTo.Location = New-Object System.Drawing.Point(67,578)
    $txtTo.Name = "txtTo"
    $txtTo.Size = New-Object System.Drawing.Size(200,70)
    $txtTo.visible=$TRUE
    
    # buttonEMailOutput
	#
	$buttonEMailOutput.Location = '660, 560'
	$buttonEMailOutput.Name = "buttonEMailOutput"
	$buttonEMailOutput.Size = '102, 23'
	#$buttonEMailOutput.TabIndex = 10
	$buttonEMailOutput.Text = "E-Mail Output"
	$buttonEMailOutput.UseVisualStyleBackColor = $True
	$buttonEMailOutput.add_Click($GetData)
	
    
$rtbPerfData.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$rtbPerfData.BorderStyle = [System.Windows.Forms.BorderStyle]::None 
$rtbPerfData.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
$rtbPerfData.Font = New-Object System.Drawing.Font("Lucida Console",8.25,0,3,1)
$rtbPerfData.Location = New-Object System.Drawing.Point(13,120)
$rtbPerfData.Name = "rtbPerfData"
$rtbPerfData.Size = New-Object System.Drawing.Size(450,200)
$rtbPerfData.TabIndex = 6
$rtbPerfData.Text = ""


$BrowseButton = New-Object System.Windows.Forms.Button
$BrowseButton.Location = New-Object System.Drawing.Size(420,10)
$BrowseButton.Size = New-Object System.Drawing.Size(75,20)
$BrowseButton.TabIndex = 2

$BrowseButton.Text = "Browse"
$BrowseButton.Add_Click({
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.DefaultExt = '.txt'
$dialog.Filter = 'All Files|*.*'
$dialog.FilterIndex = 0
$dialog.InitialDirectory = $home
$dialog.Multiselect = $false
$dialog.RestoreDirectory = $true
$dialog.Title = "Select a Input file"
$dialog.ValidateNames = $true
$dialog.ShowDialog()
$txtComputerName1.Text = $dialog.FileName;})
$form1.Controls.Add($BrowseButton)

	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
   
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Show the Form
	return $form1.ShowDialog()

} #End Function

#Call OnApplicationLoad to initialize
if(OnApplicationLoad -eq $true)
{
	#Create the form
	Call-SystemInformation_pff | Out-Null
	#Perform cleanup
	OnApplicationExit
}

}

Get-DiskSpace


