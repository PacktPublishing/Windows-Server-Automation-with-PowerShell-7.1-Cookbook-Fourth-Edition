# 10.5 - Creating an iSCSI Target

# Run from SS1 as Reskit\Administrator

# 1. Installing the iSCSI target feature on SS1
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature FS-iSCSITarget-Server

# 2. Exploring iSCSI target server settings:
Get-IscsiTargetServerSetting

# 3. Creating a folder on SS1 to hold the iSCSI virtual disk
$NIHT = @{
  Path        = 'C:\iSCSI' 
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT | Out-Null

# 4. Creating an iSCSI virtual disk (that is a LUN)
$LP = 'C:\iSCSI\ITData.Vhdx'
$LN = 'ITTarget'
$VDHT = @{
   Path        = $LP
   Description = 'LUN For IT Group'
   SizeBytes   = 500MB
 }
New-IscsiVirtualDisk @VDHT

# 5. Setting the iSCSI target, specifying who can initiate an iSCSI connection
$THT = @{
  TargetName   = $LN
  InitiatorIds = 'IQN:*'
}
New-IscsiServerTarget @THT

# 6. Creating iSCSI disk target mapping LUN name to a local path
Add-IscsiVirtualDiskTargetMapping -TargetName $LN -Path $LP



# For testing and Undo:

$LP = 'C:\iSCSI\ITData.Vhdx'
Get-IscsiServerTarget | Remove-IscsiServerTarget
Get-IscsiVirtualDisk | Remove-IscsiVirtualDisk
Remove-item $LP
