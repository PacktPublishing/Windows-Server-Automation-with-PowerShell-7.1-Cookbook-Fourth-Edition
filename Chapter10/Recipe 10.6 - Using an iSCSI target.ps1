# Recipe 10.6 - Using an ISCSI Target
#
#  Run from SRV1

# 1. Adjusting the iSCSI service to auto start, then start the service 
Set-Service MSiSCSI -StartupType 'Automatic'
Start-Service MSiSCSI

# 2. Setting up the portal to SS1
$PHT = @{
  TargetPortalAddress     = 'SS1.Reskit.Org'
  TargetPortalPortNumber  = 3260
}
New-IscsiTargetPortal @PHT
                   
# 3. Finding and viewing the ITTarget on the portal
$Target  = Get-IscsiTarget | 
               Where-Object NodeAddress -Match 'ITTarget'
$Target 

# 4. Connecting to the target on SS1
$CHT = @{
  TargetPortalAddress = 'SS1.Reskit.Org'
  NodeAddress         = $Target.NodeAddress
}
Connect-IscsiTarget  @CHT
                    

# 5. Viewing the iSCSI disk from FS1 on SRV1
$ISD =  Get-Disk | 
  Where-Object BusType -eq 'iscsi'
$ISD | 
  Format-Table -AutoSize

# 6. Turning disk online and making disk R/W
$ISD | 
  Set-Disk -IsOffline  $False
$ISD | 
  Set-Disk -Isreadonly $False

# 7. Formatting the volume on SS1
$NVHT = @{
  FriendlyName = 'ITData'
  FileSystem   = 'NTFS'
  DriveLetter  = 'I'
}
$ISD | 
  New-Volume @NVHT

# 8. Using the drive as a local drive
Set-Location -Path I:
New-Item -Path I:\  -Name ITData -ItemType Directory |
  Out-Null
'Testing 1-2-3' | 
  Out-File -FilePath I:\ITData\Test.Txt
Get-ChildItem I:\ITData



<#  Undo it

Disconnect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:srv1-salestarget-target -Confirm:$false

#>