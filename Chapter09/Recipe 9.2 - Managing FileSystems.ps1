# Recipe 9.2 - Managing Filesystems

# Run on SRV1
# SRV1, SRV2 has 8 extra disks that are 'bare' and just added to the VMs
# In 9.1, you used the first 2, in this recipe you use the third.

# 1. Getting disk to use on SRV1
$Disk = Get-Disk |
          Where-Object PartitionStyle -eq 'RAW' |
            Select-Object -First 1

# 2. Viewing disk            
$Disk | Format-List

# 3. Viewing partitions on the disk
$Disk | Get-Partition

# 4. Initializing this disk amd creating 4 partitions
Initialize-Disk -Number $Disk.DiskNumber -PartitionStyle GPT
New-Partition -DiskNumber $Disk.DiskNumber  -DriveLetter W -Size 1gb
New-Partition -DiskNumber $Disk.DiskNumber  -DriveLetter X -Size 15gb
New-Partition -DiskNumber $Disk.DiskNumber  -DriveLetter Y -Size 15gb
$UMHT= @{UseMaximumSize = $true}
New-Partition -DiskNumber $Disk.DiskNumber  -DriveLetter Z @UMHT

# 5. Formatting each partition
$FHT1 = @{
  DriveLetter        = 'W'
  FileSystem         = 'FAT' 
  NewFileSystemLabel = 'w-fat'
}
Format-Volume @FHT1
$FHT2 = @{
  DriveLetter        = 'X'
  FileSystem         = 'exFAT'
  NewFileSystemLabel = 'x-exFAT'
}
Format-Volume @FHT2
$FHT3 = @{
  DriveLetter        = 'Y'
  FileSystem         = 'FAT32'
  NewFileSystemLabel = 'Y-FAT32'
}
Format-Volume  @FHT3
$FHT4 = @{
  DriveLetter        = 'Z'
  FileSystem         = 'ReFS'
  NewFileSystemLabel = 'Z-ReFS'
}
Format-Volume @FHT4

# 6. Getting volumes on SRV1
Get-Volume | Sort-Object DriveLetter