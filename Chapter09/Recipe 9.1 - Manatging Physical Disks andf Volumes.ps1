# Recipe 9.1 - Managing physical disks and volumes
#
# Run on SRV1
# SRV1, SRV2 has 8 extra disks that are 'bare' and just added to the VM

# 0. Add new disks to the SRV1, SRV2 VMs
# Run this this step on VM host
# Assumes a single C:, and SCSI bus 0 is unoccupied.
#

#
# 0.1 Turning off the VMs
Get-VM -Name SRV1, SRV2 | Stop-VM -Force

# 0.2 Getting Path for hard disks for SRV1, SRV2
$Path1   = Get-VMHardDiskDrive -VMName SRV1
$Path2   = Get-VMHardDiskDrive -VMName SRV2
$VMPath1 = Split-Path -Parent $Path1.Path 
$VMPath2 = Split-Path -Parent $Path2.Path 


# 0.3 Creating 8 disks to SRV1/2 for storage chapter
0..7 | ForEach-Object {
  New-VHD -Path $VMPath1\SRV1-D$_.vhdx -SizeBytes 64gb -Dynamic |
    Out-Null
  New-VHD -Path $VMPath2\SRV2-D$_.vhdx -SizeBytes 64gb -Dynamic | 
    Out-Null
}

# 0.4 Adding disks to SRV1, SRV2
0..7 | ForEach-Object {
  $DHT1 = @{
    VMName           = 'SRV1'
    Path             = "$VMPath1\SRV1-D$_.vhdx" 
    ControllerType   = 'SCSI'
    ControllerNumber = 0 
  }
  $DHT2 = @{
    VMName           = 'SRV2' 
    Path             =  "$VMPath2\SRV2-D$_.vhdx"
    ControllerType   = 'SCSI' 
    ControllerNumber =  0
  }
  Add-VMHardDiskDrive @DHT1
  Add-VMHardDiskDrive @DHT2
}  

# 0.5 Checking VM disks for SRV1, SRV2
Get-VMHardDiskDrive -VMName SRV1 | Format-Table
Get-VMHardDiskDrive -VMName SRV2 | Format-Table

# 0.6 Restarting VMs
Start-VM -VMName SRV1
Start-VM -VMName SRV2

#
# Run remainder of this recipe on SRV1
#

# 1. Getting the first new physical disk on SRV1
$Disks = Get-Disk |
           Where-Object PartitionStyle -eq Raw |
             Select-Object -First 1
$Disks | Format-Table -AutoSize

# 2. Initializing the first disk
$Disks | 
  Where-Object PartitionStyle -eq Raw |
    Initialize-Disk -PartitionStyle GPT

# 3. Re-displaying all disks in SRV1
Get-Disk |
  Format-Table -AutoSize

# 4. Viewing volumes on SRV1
Get-Volume | Sort-Object -Property DriveLetter

# 5. Creating a F: volume in disk 1
$NVHT1 = @{
  DiskNumber   =  $Disks[0].DiskNumber
  FriendlyName = 'Files' 
  FileSystem   = 'NTFS' 
  DriveLetter  = 'F'
}
New-Volume @NVHT1 

# 6. Creating two partitions in disk 2 - first create S volume
Initialize-Disk -Number 2 -PartitionStyle MBR
New-Partition -DiskNumber 2  -DriveLetter S -Size 32gb
     
# 7. Creating a second partition T on disk 2
New-Partition -DiskNumber 2  -DriveLetter T -UseMaximumSize

# 8. Formatting S: and T:
$NVHT1 = @{
  DriveLetter        = 'S'
  FileSystem         = 'NTFS' 
  NewFileSystemLabel = 'GD Shows'}
Format-Volume @NVHT1
$NVHT2 = @{
  DriveLetter        = 'T'
  FileSystem         = 'FAT32' 
  NewFileSystemLabel = 'GD Pictures'}
Format-Volume @NVHT2

# 9. Getting partitions on SRV1
Get-Partition  | 
  Sort-Object -Property DriveLetter |
    Format-Table -Property DriveLetter, Size, Type, *name

# 10. Getting volumes on SRV1
Get-Volume | 
  Sort-Object -Property DriveLetter

# 11. Viewing disks in SRV1
Get-Disk | Format-Table


# Testing - remove disks from VMs 
#         - then you can re-run step 0.
# run on hv host
Get-VM -Name SRV1, SRV2 | Stop-VM -Force
"VMs stopped"
$Path1   = Get-VMHardDiskDrive -VMName SRV1
$Path2   = Get-VMHardDiskDrive -VMName SRV2
$VMPath1 = Split-Path -Parent $Path1.Path | select -first 1
$VMPath2 = Split-Path -Parent $Path2.Path | Select -first 1

$disks1 = $path1 | where {$_.path -match '-D'} 
$disks2 = $path2 | where {$_.path -match '-D'} 
"Found Disks"
# remove disks from SRV1
foreach ($Disk in $Disks1) {
  $DHT = @{
    Controllertype     = $Disk.ControllerType
    ControllerNumber   = $Disk.ControllerNumber
    ControllerLocation = $Disk.ControllerLocation
  }
  Remove-VMHardDiskDrive @DHT -VMName SRV1
}
"Disks removed from SRV1"
# remove disks from SRV2
foreach ($Disk in $Disks2) {
  $DHT = @{
    Controllertype     = $Disk.ControllerType
    ControllerNumber   = $Disk.ControllerNumber
    ControllerLocation = $Disk.ControllerLocation
  }
  Remove-VMHardDiskDrive @DHT -VMName SRV2
}
"Disks removed from SRV2"
# Remove VHDs

ls -path $VMPath1\*-d*  | ri
ls -path $VMPath2\*-d*  | ri
"VHDX files purged"
