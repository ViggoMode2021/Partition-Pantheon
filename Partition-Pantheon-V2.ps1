# Partition Pantheon - A removable storage device partitioning tool written in PowerShell. 

# 1 mb (megabyte) = 1000 kb (kilobyte)
# 1 gb (gigabyte) = 1000 mb (megabyte)

function RegBackup{

$Drives = [System.IO.DriveInfo]::GetDrives() # Gets removable drives
$Removable_Drives = $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady }
[string]$Removable_Drives = $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } # Selects removable and ready drives

$Removable_Drives_For_Checking = $Removable_Drives.replace(":\", "") ## Get this though

$Removable_Drives_For_Checking = $Removable_Drives_For_Checking.replace(" ", ",")

$Index_Position = $Removable_Drives_For_Checking.IndexOf(",")

$Removable_Drive_Letter_1 = $Removable_Drives_For_Checking.Substring(0, $Index_Position)

$Removable_Drive_Letter_2 = $Removable_Drives_For_Checking.Substring($Index_Position + 1)

if($Removable_Drives_Count -eq 3){

Write-Host "There is already a registry partition on Disk 1." -ForeGroundColor "Yellow"

$Registry_Partition_Choice = Read-Host "What would you like to do? `nPress 1 to see what is on it. `n2 to add another registry file. `n3 to delete a partition."

if($Registry_Partition_Choice -eq "1"){

Get-ChildItem -Path $Removable_Drives
gwmi win32_logicaldisk | ?{$_.DeviceId -notlike "C:"} | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}

return 

}

if($Registry_Partition_Choice -eq "2"){


return 

}


if($Registry_Partition_Choice -eq "3"){

do{

$Removable_Drive_To_Delete = Read-Host "`nPlease type the drive letter"

}

until($Removable_Drives -match $Removable_Drive_To_Delete)

Remove-Partition -DriveLetter $Removable_Drive_To_Delete

return 

}

do{

$Registry_Backup_Partition_Name = Read-Host "What would you like to name the registry partition?"

}

until($Registry_Backup_Partition_Name.Length -gt 1 -and -not $Registry_Backup_Partition_Name.StartsWith("\d"))

New-Partition -DiskNumber 1 -UseMaximumSize | Format-Volume -Filesystem NTFS -NewFileSystemLabel $Registry_Backup_Partition_Name

Write-Host "'$Registry_Backup_Partition_Name' has been set as the name for the registry partition." -ForeGroundColor "Green"

# Allocate 2nd partition letter

do{

$Registry_Drive_Letter = Read-Host "What drive letter would you like to give the registry partition (besides 'C', '$Removable_Drive_Letter_1', or '$Removable_Drive_Letter_2')"

}

until($Registry_Drive_Letter.Length -eq 1 -and $Registry_Drive_Letter -notmatch "\d" -and -not $Registry_Drive_Letter.StartsWith("C") -and $Registry_Drive_Letter -ne $Removable_Drive_Letter_1 -and $Registry_Drive_Letter -ne $Removable_Drive_Letter_2)

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

exit

}

# Check drives and other pertinent information at start of script 

$User_ID = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$Principal_ID = New-Object System.Security.Principal.WindowsPrincipal($User_ID)

    if ($Principal_ID.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){

      Write-Host "Partition Pantheon is being run with Admin priviledges. You are all set to go." -ForeGroundColor "Green"

    }

    else{

      Write-Host "Please run Partition Pantheon with Admin priviledges in order to make changes to your removable disk." -ForegroundColor "Red" 
    
        }

$Desktop = [Environment]::GetFolderPath("Desktop")

$Drives = [System.IO.DriveInfo]::GetDrives() # Gets removable drives
$Removable_Drives = $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady }
[string]$Removable_Drives = $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } # Selects removable and ready drives

$Removable_Drives_For_Checking = $Removable_Drives.replace(":\", "") ## Get this though

$Removable_Drives_For_Checking = $Removable_Drives_For_Checking.replace(" ", ",")

$Index_Position = $Removable_Drives_For_Checking.IndexOf(",")

if($Removable_Drive_Letter_1 -eq $null){

}

else{

$Removable_Drive_Letter_1 = $Removable_Drives_For_Checking.Substring(0, $Index_Position)

}

if($Removable_Drive_Letter_2 -eq $null){

}

else{

$Removable_Drive_Letter_2 = $Removable_Drives_For_Checking.Substring($Index_Position + 1)

}

$Removable_Drives_Count =  $Drives | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } | Measure-Object | Select -expand count

$global:Removable_Drive_Letter_1 = $Removable_Drive_Letter_1

$global:Removable_Drive_Letter_2 = $Removable_Drive_Letter_2

if($Removable_Drives){

    Write-Host "Welcome to Partition Pantheon! Your current removable drives are: '$Removable_Drives'" -ForegroundColor "Green" # Displays available removable drives
    $Continue_Prompt = Read-Host "`nPress 1 to exit Partition Pantheon, `n2 to see more information about the removable drive(s), `n3 to add a new partition to back up your Windows Registry, `n4 to completely wipe the drives from your removable disk."
    if($Continue_Prompt -eq "1"){
    Write-Host "Exited Partition Pantheon." -ForeGroundColor "Yellow"
    return
    }
    if($Continue_Prompt -eq "2"){
    Write-Host "$Removable_Drives" -ForegroundColor Cyan
    Get-ChildItem -Path $Removable_Drives
    gwmi win32_logicaldisk | ?{$_.DeviceId -notlike "C:"} | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}
    return
    Write-Host "Exited Partition Pantheon." -ForeGroundColor "Yellow"
    }
    if($Continue_Prompt -eq "3"){
    Invoke-Expression RegBackup
    }
    if($Continue_Prompt -eq "4"){
    $Delete_Partition = Read-Host "Type 1 to delete a certain drive or type 2 to completely remove the removable drives on disk 1."
    if($Delete_Partition -eq "1"){
    
    Write-Host "Which drive would you like to remove? $Removable_Drives"  -ForegroundColor "Red"

    do{

    $Removable_Drive_To_Delete = Read-Host "`nPlease type the drive letter"

    }

    until($Removable_Drives -match $Removable_Drive_To_Delete)

    Remove-Partition -DriveLetter $Removable_Drive_To_Delete

    Write-Host "Deleted partition $Removable_Drive_To_Delete!" -ForegroundColor "Red"

    return

    }

    $Wipe_Confirmation = Read-Host "Type 'confirm' if you would like to completely wipe a selected removable drive or all of the removable drives on disk 1. Press any other key to exit."
    if($Wipe_Confirmation -eq 'confirm'){
    Clear-Disk -Number “1” -RemoveData
    return
    Write-Host "Exited Partition Pantheon." -ForeGroundColor "Yellow"
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

$Partition_1_Destination = "$Partition_1_Letter" + ":\"

# Add do until

do{
    
$Partition_1_Space = Read-Host "How much space (in MB) do you want to allocate to Partition 1?"

}

until ($Partition_1_Space -match "\d")

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

# Select path to move items to

do{

$Partition_1_File_Path_Request = Read-Host "Where would you like to move your $Partition_1_File_Type from? `nPress 1 to type the full path to the location of your files, `n2 to select the desktop `n3 to select the documents directory `n4 to display the subdirectories on the desktop and choose one" 

}

until($Partition_1_File_Path_Request -eq "1" -or $Partition_1_File_Path_Request -eq "2" -or $Partition_1_File_Path_Request -eq "3" -or $Partition_1_File_Path_Request -eq "4")

# If user decides to type full path:

if($Partition_1_File_Path_Request -eq "1"){

do{
    
$Partition_1_File_Path = Read-Host "Please type the full path to the location of your files."

Write-Host "Please note that you cannot proceed unless the specified path exists on this machine." -ForeGroundColor "Yellow"

}

until(Test-Path -Path $Partition_1_File_Path)

Copy-Item -Path $Partition_1_File_Path -Filter $Partition_1_File_Type -Destination $Partition_1_Destination -Recurse

Write-Host "You will move all $Partition_1_File_Type in $Partition_1_File_Path to $Partition_1_Name ($Partition_1_Letter)" -ForeGroundColor "Yellow"

$Partition_1_File_Path = $Partition_1_File_Path

}

# If user decides to select the desktop:

if($Partition_1_File_Path_Request -eq "2"){

$Partition_1_File_Path = $Desktop

Copy-Item -Path $Partition_1_File_Path -Filter $Partition_1_File_Type -Destination $Partition_1_Destination -Recurse

Write-Host "You will move all $Partition_1_File_Type in $Partition_1_File_Path to $Partition_1_Name ($Partition_1_Letter)" -ForeGroundColor "Yellow"

}

# If user decides to select the documents directory:

if($Partition_1_File_Path_Request -eq "3"){

$Partition_1_File_Path = [Environment]::GetFolderPath('Personal')

Copy-Item -Path $Partition_1_File_Path -Filter $Partition_1_File_Type -Destination $Partition_1_Destination -Recurse

Write-Host "You will move all $Partition_1_File_Type in $Partition_1_File_Path to $Partition_1_Name ($Partition_1_Letter)" -ForeGroundColor "Yellow"

}

# If user decides to display all directories on desktop and choose one:

if($Partition_1_File_Path_Request -eq "4"){

Write-Host "Type the name of the desktop subdirectory displayed below" -ForegroundColor "Yellow"

$Desktop = [Environment]::GetFolderPath("Desktop")

$All_Desktop_Subdirectories = Get-ChildItem -Path $Desktop -Directory | Out-Host

Write-Host $All_Desktop_Subdirectories -ForeGroundColor "Yellow"

do{
    
$Partition_1_File_Path = Read-Host "Please type the name of the directory from the list above."

$Partiton_1_File_Path = $Desktop + "\" + $Partition_1_File_Path

Write-Host "Please note that you cannot proceed unless the specified path exists on this machine." -ForeGroundColor "Yellow"

}

until(Test-Path -Path $Partition_1_File_Path)

Copy-Item -Path $Partition_1_File_Path -Filter $Partition_1_File_Type -Destination $Partition_1_Destination -Recurse

Write-Host "You will move all $Partition_1_File_Type in $Partition_1_File_Path to $Partition_1_Name ($Partition_1_Letter)" -ForeGroundColor "Yellow"

}

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

until($Partition_2_Letter.Length -eq 1 -and $Partition_2_Letter -notmatch "\d" -and -not $Partition_2_Letter.StartsWith("C") -and -not $Partition_2_Letter.StartsWith($Partition_1_Letter))

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

$Partition_2_Destination = "$Partition_2_Letter" + ":\"

do{

$Partition_2_File_Path_Request = Read-Host "Where would you like to move your $Partition_2_File_Type from? `nPress 1 to type the full path to the location of your files, `n2 to select the desktop `n3 to select the documents directory `n4 to display the subdirectories on the desktop and choose one" 

}

until($Partition_2_File_Path_Request -eq "1" -or $Partition_2_File_Path_Request -eq "2" -or $Partition_2_File_Path_Request -eq "3" -or $Partition_2_File_Path_Request -eq "4")

# If user decides to type full path:

if($Partition_2_File_Path_Request -eq "1"){

do{
    
$Partition_2_File_Path = Read-Host "Please type the full path to the location of your files."

Write-Host "Please note that you cannot proceed unless the specified path exists on this machine." -ForeGroundColor "Yellow"

}

until(Test-Path -Path $Partition_2_File_Path)

Copy-Item -Path $Partition_2_File_Path -Filter $Partition_2_File_Type -Destination $Partition_2_Destination -Recurse

Write-Host "You will move all $Partition_2_File_Type in $Partition_2_File_Path to $Partition_2_Name ($Partition_2_Letter)" -ForeGroundColor "Yellow"

$Partition_2_File_Path = $Partition_2_File_Path

}

# If user decides to select the desktop:

if($Partition_2_File_Path_Request -eq "2"){

$Partition_2_File_Path = $Desktop

Copy-Item -Path $Partition_2_File_Path -Filter $Partition_2_File_Type -Destination $Partition_2_Destination -Recurse

Write-Host "You will move all $Partition_2_File_Type in $Partition_2_File_Path to $Partition_2_Name ($Partition_2_Letter)" -ForeGroundColor "Yellow"

}

# If user decides to select the documents directory:

if($Partition_2_File_Path_Request -eq "3"){

$Partition_2_File_Path = [Environment]::GetFolderPath('Personal')

Copy-Item -Path $Partition_2_File_Path -Filter $Partition_2_File_Type -Destination $Partition_2_Destination -Recurse

Write-Host "You will move all $Partition_2_File_Type in $Partition_2_File_Path to $Partition_2_Name ($Partition_2_Letter)" -ForeGroundColor "Yellow"

}

# If user decides to display all directories on desktop and choose one:

if($Partition_2_File_Path_Request -eq "4"){

Write-Host "Type the name of the desktop subdirectory displayed below" -ForegroundColor "Yellow"

$Desktop = [Environment]::GetFolderPath("Desktop")

$All_Desktop_Subdirectories = Get-ChildItem -Path $Desktop -Directory | Out-Host

Write-Host $All_Desktop_Subdirectories -ForeGroundColor "Yellow"

do{
    
$Partition_2_File_Path = Read-Host "Please type the name of the directory from the list above."

$Partiton_1_File_Path = $Desktop + "\" + $Partition_2_File_Path

Write-Host "Please note that you cannot proceed unless the specified path exists on this machine." -ForeGroundColor "Yellow"

}

until(Test-Path -Path $Partition_2_File_Path)

Copy-Item -Path $Partition_2_File_Path -Filter $Partition_2_File_Type -Destination $Partition_2_Destination -Recurse

Write-Host "You will move all $Partition_2_File_Type in $Partition_2_File_Path to $Partition_2_Name ($Partition_2_Letter)" -ForeGroundColor "Yellow"

}

Write-Host "Success! You have successfully created $Partition_1_Name with the letter $Partition_1_Destination and size of $Partition_1_Space in MB and $Partition_2_Name with the letter $Partition_2_Destination and size of
$Partition_2_Space in MB" -ForegroundColor "Green"

do{

$Registry_Backup = Read-Host "`nWould you like to back up the registry as well? You may also backup specific hives if you wish. Press 1 for yes and 2 for no."

}

until($Registry_Backup -eq "1" -or $Registry_Backup -eq "2")

if($Registry_Backup -eq "1"){

RegBackup 

}

if($Registry_Backup -eq "2"){

Write-Host "All set! Thank you for using Partition Pantheon." -ForeGroundColor Cyan

##$driveEject = New-Object -comObject Shell.Application
#$driveEject.Namespace(17).ParseName($Partition_1_Destination).InvokeVerb("Eject")
}

}

Partition_Pantheon
