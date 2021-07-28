# Recipe 12.5 - Configuring VM Hardware
#
# Run on HV1, using PSDirect VM

# 1. Turning off the PSDirect VM
Stop-VM -VMName PSDirect
Get-VM -VMName PSDirect 

# 2. Setting the startup order in the VM's BIOS
$Order = 'IDE','CD','LegacyNetworkAdapter','Floppy'
Set-VMBios -VmName PSDirect -StartupOrder $Order
Get-VMBios PSDirect

# 3. Setting and viewing CPU count for PSDirect
Set-VMProcessor -VMName PSDirect -Count 2
Get-VMProcessor -VMName PSDirect |
  Format-Table VMName, Count

# 4. Setting and viewing PSDirect memory
$VMHT = [ordered] @{
  VMName               = 'PSDirect'
  DynamicMemoryEnabled = $true
  MinimumBytes         = 512MB
  StartupBytes         = 1GB
  MaximumBytes         = 2GB
}
Set-VMMemory @VMHT
Get-VMMemory -VMName PSDirect

# 5. Adding and viewing a ScsiController in the PSDirect VM
Add-VMScsiController -VMName PSDirect
Get-VMScsiController -VMName PSDirect

# 6. Starting the PSDirect VM
Start-VM -VMName PSDirect
Wait-VM -VMName PSDirect -For IPAddress

# 7. Creating a new VHDX file for the PSDirect VM
$VHDPath = 'C:\VM\VHDs\PSDirect-D.VHDX'
New-VHD -Path $VHDPath -SizeBytes 8GB -Dynamic

# 8. Getting Controller number of the newly added SCSI controller
$VM    = Get-VM -VMName PSDirect
$SCSIC = Get-VMScsiController -VM $VM| 
           Select-Object -Last 1 

# 9. Adding the VHD to the ScsiController
$VHDHT = @{
    VMName            = 'PSDirect'
    ControllerType    = $SCSIC.ControllerNumber
    ControllerNumber  =  0
    ControllerLocation = 0
    Path               = $VHDPath
}
Add-VMHardDiskDrive @VHDHT

# 10. Viewing drives in the PSDirect VM
Get-VMScsiController -VMName PSDirect |
  Select-Object -ExpandProperty Drives





PS C:\foo> 