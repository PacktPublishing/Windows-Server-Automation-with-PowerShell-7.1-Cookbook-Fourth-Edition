# 9.4 - Managing Storage Replica
# 
# Run on SRV1, with SRV2, DC1 online

# 1. Getting disk number of the disk holding the F partition
$Part = Get-Partition -DriveLetter F
"F drive on disk [$($Part.DiskNumber)]"

# 2. Creating F: drive on SRV2
$SB = {
  $NVHT = @{
   DiskNumber   =  $using:Part.DiskNumber
    FriendlyName = 'Files' 
    FileSystem   = 'NTFS' 
    DriveLetter  = 'F'
  }
  New-Volume @NVHT
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 3. Creating content on F: on SRV1
1..100 | ForEach-Object {
  $NF = "F:\CoolFolder$_"
  New-Item -Path $NF -ItemType Directory | Out-Null
  1..100 | ForEach-Object {
    $NF2 = "$NF\CoolFile$_"
    "Cool File" | Out-File -PSPath $NF2
  }
}

# 4. Showing what is on F: locally
Get-ChildItem -Path F:\ -Recurse | Measure-Object

# 5. Examining the same drives remotely on SRV2
$SB2 = {
  Get-ChildItem -Path F:\ -Recurse |
    Measure-Object
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB2

# 6. Adding the storage replica feature to SRV1
Add-WindowsFeature -Name Storage-Replica | Out-Null

# 7. Adding the Storage Replica Feature to SRV2
$SB= {
  Add-WindowsFeature -Name Storage-Replica | Out-Null
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 8. Restarting SRV2 and waiting for the restart
$RSHT = @{
  ComputerName = 'SRV2'
  Force        = $true
}
Restart-Computer @RSHT -Wait -For PowerShell

# 9. Restarting SRV1 to finish the installation process
Restart-Computer

# 10. Creating a G: volume in disk 2 on SRV1
$SB4 = {
  $NVHT = @{
   DiskNumber   =  2
   FriendlyName = 'SRLOGS' 
   DriveLetter  = 'G'
  }
  Clear-Disk -Number 2 -RemoveData -Confirm:$False | Out-Null
  Initialize-Disk -Number 2 | Out-Null
  New-Volume @NVHT
}
Invoke-Command -ComputerName SRV1 -ScriptBlock $SB4

# 11. Creating G: volume on SRV2
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB4
  
# 12. Viewing volumes on SRV1
Get-Volume | Sort-Object -Property Driveletter

# 13. Viewing volumes on SRV2
Invoke-Command -Computer SRV2 -Scriptblock {
    Get-Volume | Sort-Object -Property Driveletter
}

# 14. Creating an SR replica group
$SRHT =  @{
  SourceComputerName       = 'SRV1'
  SourceRGName             = 'SRV1RG2'
  SourceVolumeName         = 'F:'
  SourceLogVolumeName      = 'G:'
  DestinationComputerName  = 'SRV2'
  DestinationRGName        = 'SRV2RG2'
  DestinationVolumeName    = 'F:'
  DestinationLogVolumeName = 'G:'
  LogSizeInBytes           = 2gb
}
New-SRPartnership @SRHT

# 15. Examining the volumes on SRV2
$SB5 = {
  Get-Volume |
    Sort-Object -Property DriveLetter |
      Format-Table   
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB5

# 16. Reversing the replication
$SRHT2 = @{ 
  NewSourceComputerName   = 'SRV2'
  SourceRGName            = 'SRV2RG2' 
  DestinationComputerName = 'SRV1'
  DestinationRGName       = 'SRV1RG2'
  Confirm                 = $false
}
Set-SRPartnership @SRHT2


# 17. Viewing the SR Partnership
Get-SRPartnership

# 18. Examining the files remotely on SRV2
$SB6 = {
  Get-ChildItem -Path F:\ -Recurse |
    Measure-Object 
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB6

