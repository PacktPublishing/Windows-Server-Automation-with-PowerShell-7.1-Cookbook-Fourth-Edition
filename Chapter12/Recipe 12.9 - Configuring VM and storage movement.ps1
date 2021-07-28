# Recipe 12.9 - Configuring VM and storage movement

# Run on HV1

# 1. Viewing the PSDirect VM on HV1 and verifying that it is turned on and running
Start-VM -VMName PSDirect 
Get-VM -Name PSDirect -Computer HV1

# 2. Getting the VM configuration location 
(Get-VM -Name PSDirect).ConfigurationLocation 

# 3. Getting the virtual hard drive locations
Get-VMHardDiskDrive -VMName PSDirect | 
  Format-Table -Property VMName, ControllerType, Path

# 4. Moving the VM's to the C\PSDirectNew folder
$MHT = @{
  Name                   = 'PSDirect'
  DestinationStoragePath = 'C:\PSDirectNew'
}
Move-VMStorage @MHT

# 5. Viewing the configuration details after moving the VM's storage
(Get-VM -Name PSDirect).ConfigurationLocation
Get-VMHardDiskDrive -VMName PSDirect | 
  Format-Table -Property VMName, ControllerType, Path
  
# 6. Getting the VM details for VMs from HV2
Get-VM -ComputerName HV2

# 7. Creating External virtual switch on HV2
$SB = {
  $NSHT = @{
    Name           = 'External'
    NetAdapterName = 'Ethernet'
    ALLOWmAnagementOS = $true
  }
  New-VMSwitch @NSHT
}
Invoke-Command -ScriptBlock $SB -ComputerName HV2

# 8. Enabling VM migration from both HV1 and HV2
Enable-VMMigration -ComputerName HV1, HV2

# 9. Configuring VM Migration on both hosts
$SVHT = @{
  UseAnyNetworkForMigration                 = $true
  ComputerName                              = 'HV1', 'HV2'
  VirtualMachineMigrationAuthenticationType =  'Kerberos'
  VirtualMachineMigrationPerformanceOption  = 'Compression'
}
Set-VMHost @SVHT

# 10. Moving the PSDirect VM to HV2
$Start = Get-Date
$VMHT = @{
  Name                   = 'PSDirect'
  ComputerName           = 'HV1'
  DestinationHost        = 'HV2'
  IncludeStorage         =  $true
  DestinationStoragePath = 'C:\PSDirect' # on HV2
}
Move-VM @VMHT
$Finish = Get-Date

# 11. Displaying the time taken to migrate
$OS = "Migration took: [{0:n2}] minutes"
($OS -f ($($Finish-$Start).TotalMinutes))

# 12. Checking the VMs on HV1
Get-VM -ComputerName HV1

# 13. Checking the VMs on HV2
Get-VM -ComputerName HV2

# 14. Looking at the details of the PSDirect VM on HV2
((Get-VM -Name PSDirect -Computer HV2).ConfigurationLocation)
Get-VMHardDiskDrive -VMName PSDirect -Computer HV2  |
  Format-Table -Property VMName, Path



#  run on HV2 

# 15.  Moving the PSDirect VM back to HV1
$Start2 = Get-Date
$VMHT2  = @{
    Name                  = 'PSDirect'
    ComputerName           = 'HV2'
    DestinationHost        = 'HV1'
    IncludeStorage         =  $true
    DestinationStoragePath = 'C:\vm\vhds\PSDirect' # on HV1
}
Move-VM @VMHT2
$Finish2  = Get-Date

# 15. Displaying the time taken to migrate back to HV1
$OS = "Migration back to HV1 took: [{0:n2}] minutes"
($OS -f ($($ffinish-$sStart).TotalMinutes))
