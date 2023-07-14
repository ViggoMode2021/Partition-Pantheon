# Partition Pantheon - A removable storage device partitioning tool written in PowerShell. 

# 1 mb (megabyte) = 1000 kb (kilobyte)
# 1 gb (gigabyte) = 1000 mb (megabyte)


function RegBackup{

do{

$Registry_Backup_Partition_Name = Read-Host "What would you like to name the registry partition?"

}

until($Registry_Backup_Partition_Name.Length -gt 1 -and -not $Registry_Backup_Partition_Name.StartsWith("\d"))

New-Partition -DiskNumber 1 -UseMaximumSize | Format-Volume -Filesystem NTFS -NewFileSystemLabel $Registry_Backup_Partition_Name

Write-Host "'$Registry_Backup_Partition_Name' has been set as the name for the registry partition." -ForeGroundColor "Green"

# Allocate 2nd partition letter

do{

$Registry_Drive_Letter = Read-Host "What drive letter would you like to give the registry partition (besides 'C')"

}

until($Registry_Drive_Letter.Length -eq 1 -and $Registry_Drive_Letter -notmatch "\d" -and -not $Registry_Drive_Letter.StartsWith("C"))

Write-Host "'$Registry_Drive_Letter' has been set as the drive letter for the registry partition." -ForeGroundColor "Green"

Get-Partition -DiskNumber 1 -PartitionNumber 3 | Set-Partition -NewDriveLetter $Registry_Drive_Letter

$Registry_Drive_Destination = "$Registry_Drive_Letter" + ":\"

$Registry_Partition_Space = Read-Host "How much space (in MB) do you want to allocate to the registry partition?"

$Registry_Partition_Space = $Registry_Partition_Space

$Registry_Partition_Space = (($Registry_Partition_Space / 1) * 1MB)

Resize-Partition -DiskNumber 1 -PartitionNumber 3 -Size ($Registry_Partition_Space)

Write-Host "'$Registry_Partition_Space MB' has been set as the size for Partition 3." -ForeGroundColor "Green"

$Hive_Backup_Count = $Number_Of_Hives_To_Backup

$Hives = @()

1..$Number_Of_Hives_To_Backup | ForEach-Object {

Write-Host "Windows Registry Hives are: HKLM, HKCR, HKCU" -ForegroundColor "Yellow"

do{

$Selected_Hive = Read-Host "Write a name of one of the $Hive_Backup_Count hives you wish to backup."

}

until($Selected_Hive -eq "HKLM" -or $Selected_Hive -eq "HKCR" -or $Selected_Hive -eq "HKCU")

reg export $Selected_Hive "$Registry_Drive_Destination\$Selected_Hive.reg" 

}

$Hives

Write-Host "You successfully backed up $Number_Of_Hives_To_Backup to $Registry_Drive_Letter" -ForegroundColor "Green"

}

$Desktop = [Environment]::GetFolderPath("Desktop")

$Drives = [System.IO.DriveInfo]::GetDrives() # Gets removable drives
$Removable_Drives = $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } # Selects removable and ready drives
if($Removable_Drives){
    Write-Host "Current removable drives are: $Removable_Drives" -ForegroundColor "Green" # Displays available removable drives
    $Continue_Prompt = Read-Host "Would you like to continue with the script? Press 1 for reformatting, 2 for no, and 3 to see what files are on the removable drive(s). Press 4 if you want to completely wipe the removable drives.
    Press 5 if you want to add a new partition to back up the registry."
    if($Continue_Prompt -eq "1"){ 
    Write-Host "WARNING!! - FOLLOWING THROUGH WITH THE PROMPTS WILL OVERRIDE YOUR CURRENT SETTINGS AND FILES IN YOUR REMOVABLE DRIVE!" -ForeGroundColor "Red"
    Partition_Pantheon # Runs main function
    }
    if($Continue_Prompt -eq "2"){
    Write-Host "Exiting Partition Pantheon.." -ForeGroundColor Gray
    return
    }
    if($Continue_Prompt -eq "5"){
    Invoke-Expression RegBackup
    }
    if($Continue_Prompt -eq "3"){
    Write-Host "$Removable_Drives" -ForegroundColor Cyan
    Get-ChildItem -Path $Removable_Drives
    gwmi win32_logicaldisk | ?{$_.DeviceId -notlike "C:"} | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}
    return
    Write-Host "Exiting Partition Pantheon.." -ForeGroundColor Gray
    }
    if($Continue_Prompt -eq "4"){
    $Wipe_Confirmation = Read-Host "Type 'confirm' if you would like to completely wipe the removable drives on disk 1. Press any other key to exit."
    if($Wipe_Confirmation -eq 'confirm'){
    Clear-Disk -Number “1” -RemoveData
    return
    Write-Host "Exiting Partition Pantheon.." -ForeGroundColor Gray
    }
    else{
    return
    }
}
else{
 Write-Host "No removable drives found." -ForegroundColor "Red"
 }
}
#>

diskmgmt.msc

function Partition_Pantheon{

Get-Disk -Number 1

# Name 1st partition

do{

$Partition_1_Name = Read-Host "`n`n`nWhat would you like to name the first partition?"

}

until($Partition_1_Name.Length -gt 1 -and -not $Partition_1_Name.StartsWith("\d"))

New-Partition -DiskNumber 1 -UseMaximumSize | Format-Volume -Filesystem NTFS -NewFileSystemLabel $Partition_1_Name

Write-Host "'$Partition_1_Name' has been set as the name for Partition 1." -ForeGroundColor "Green"

# Allocate 1st partition letter

do{

$Partition_1_Letter = Read-Host "What drive letter would you like to give the first partition (besides 'C')"

}

until($Partition_1_Letter.Length -eq 1 -and $Partition_1_Letter -notmatch "\d" -and -not $Partition_1_Letter.StartsWith("C"))

Write-Host "'$Partition_1_Letter' has been set as the drive letter for Partition 1." -ForeGroundColor "Green"

$Partition_1_Destination = "$Partition_1_Letter" + ":\"

Write-Host $Partition_1_Destination

Get-Partition -DiskNumber 1 | Set-Partition -NewDriveLetter $Partition_1_Letter

$Partition_1_Space = Read-Host "How much space (in MB) do you want to allocate to Partition 1?"

$Partition_1_Space = $Partition_1_Space

$Partition_1_Space = (($Partition_1_Space / 1) * 1MB)

Write-Host "'$Partition_1_Space MB' has been set as the size for Partition 2." -ForeGroundColor "Green"

Resize-Partition -DiskNumber 1 -PartitionNumber 1 -Size ($Partition_1_Space)

gwmi win32_logicaldisk | ?{$_.DeviceId -notlike "C:"} | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}

do{

$Partition_1_File_Type = Read-Host "What file type would you like to move?"

Write-Host "You decided to move $Partition_1_File_Type to the first partition." -ForegroundColor "Green"

}

until($Partition_1_File_Type -match "^\.[^.]+$")

$Partition_1_File_Type = "*" + "$Partition_1_File_Type"

# Name 2nd partition

do{

$Partition_2_Name = Read-Host "What would you like to name the second partition?"

}

until($Partition_2_Name.Length -gt 1 -and -not $Partition_2_Name.StartsWith("\d"))

Write-Host "'$Partition_2_Name' has been set as the name for Partition 2." -ForeGroundColor "Green"

# Allocate 2nd partition letter

do{

$Partition_2_Letter = Read-Host "What drive letter would you like to give the second partition (besides 'C')"

}

until($Partition_2_Letter.Length -eq 1 -and $Partition_2_Letter -notmatch "\d" -and -not $Partition_2_Letter.StartsWith("C"))

Write-Host "'$Partition_2_Letter' has been set as the drive letter for Partition 2." -ForeGroundColor "Green"

New-Partition -DiskNumber 1 -UseMaximumSize | Format-Volume -Filesystem NTFS -NewFileSystemLabel $Partition_2_Name

Get-Partition -DiskNumber 1 -PartitionNumber 2 | Set-Partition -NewDriveLetter $Partition_2_Letter

$Partition_2_Space = Read-Host "How much space (in MB) do you want to allocate to Partition 2?"

$Partition_2_Space = $Partition_2_Space

$Partition_2_Space = (($Partition_2_Space / 1) * 1MB)

Resize-Partition -DiskNumber 1 -PartitionNumber 2 -Size ($Partition_2_Space)

Write-Host "'$Partition_2_Space MB' has been set as the size for Partition 2." -ForeGroundColor "Green"

do{

$Partition_2_File_Type = Read-Host "What file type would you like to move to the second partition"

Write-Host "You decided to move $Partition_2_File_Type to the second partition." -ForegroundColor "Green"

}

until($Partition_2_File_Type -match "^\.[^.]+$")

$Partition_2_File_Type = "*" + "$Partition_2_File_Type"

$Partition_1_Destination = "$Partition_1_Letter" + ":\"

$Partition_2_Destination = "$Partition_2_Letter" + ":\"

if($Partition_1_File_Type -eq "*.py"){

$Partition_1_File_Path = $Desktop + '\Python'

}

if($Partition_2_File_Type -eq "*.ps1"){

$Partition_2_File_Path = $Desktop + '\PowerShell'

}

Copy-Item -Path $Partition_1_File_Path -Filter $Partition_1_File_Type -Destination $Partition_1_Destination -Recurse

Copy-Item -Path $Partition_2_File_Path -Filter $Partition_2_File_Type -Destination $Partition_2_Destination -Recurse

#$driveEject = New-Object -comObject Shell.Application
#$driveEject.Namespace(17).ParseName($Partition_1_Destination).InvokeVerb("Eject")

Write-Host "Success! You have successfully created $Partition_1_Name with the letter $Partition_1_Destination and size of $Partition_1_Space in MB and $Partition_2_Name with the letter $Partition_2_Destination and size of
$Partition_2_Space in MB" -ForegroundColor "Green"

do{

$Registry_Backup = Read-Host "`n`n`nWould you like to back up the registry as well? You may also backup specific hives if you wish. Press 1 for yes and 2 for no."

}

until($Registry_Backup -eq "1" -or $Registry_Backup -eq "2")

if($Registry_Backup -eq "1"){

RegBackup 

}

if($Registry_Backup -eq "2"){

Write-Host "All set! Thank you for using Partition Pantheon." -ForeGroundColor Cyan
}

}

###
Partition_Pantheon
