# Recipe 12.11 - Managing VM Checkpoints

# Run on HV1

# 1. Creating credentials for PSDirect
$RKAn = 'Wolf\Administrator'
$PS   = 'Pa$$w0rd'
$RKP  = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T = 'System.Management.Automation.PSCredential'
$RKCred = New-Object -TypeName $T -ArgumentList $RKAn,$RKP

# 2. Examining the C:\ in the PSDirect VM before we start
$SB = { Get-ChildItem -Path C:\ | Format-Table}
$ICHT = @{
  VMName      = 'PSDirect'
  ScriptBlock = $SB
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 3. Creating a checkpoint of PSDirect on HV
$CPHT = @{
  VMName       = 'PSDirect'
  ComputerName = 'HV1'
  SnapshotName = 'Snapshot1'
}
Checkpoint-VM @CPHT

# 4. Examining the files created to support the checkpoints
$Parent = Split-Path -Parent (Get-VM -Name PSdirect |
            Select-Object -ExpandProperty HardDrives).Path |
              Select-Object -First 1
Get-ChildItem -Path $Parent

# 5. Creating some content in a file on PSDirect and displaying it
$SB = {
  $FileName1 = 'C:\File_After_Checkpoint_1'
  Get-Date | Out-File -FilePath $FileName1
  Get-Content -Path $FileName1
}
$ICHT = @{
  VMName      = 'PSDirect'
  ScriptBlock = $SB
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 6. Taking a second checkpoint
$SNHT = @{
  VMName        = 'PSDirect'
  ComputerName  = 'HV1'  
  SnapshotName  = 'Snapshot2'
}
Checkpoint-VM @SNHT

# 7. Viewing the VM checkpoint details for PSDirect
Get-VMSnapshot -VMName PSDirect

# 8. Looking at the files supporting the two checkpoints
Get-ChildItem -Path $Parent

# 9. Creating and displaying another file in PSDirect
#    (i.e. after you have taken Snapshot2)
$SB = {
  $FileName2 = 'C:\File_After_Checkpoint_2'
  Get-Date | Out-File -FilePath $FileName2
  Get-ChildItem -Path C:\ -File | Format-Table 
}
$ICHT = @{
  VMName    = 'PSDirect'
  ScriptBlock = $SB 
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 10. Restoring the PSDirect VM back to the checkpoint named Snapshot1
$Snap1 = Get-VMSnapshot -VMName PSDirect -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 11. Seeing what files we have now on PSDirect
$SB = {
  Get-ChildItem -Path C:\ | Format-Table
}
$ICHT = @{
  VMName    = 'PSDirect'
  ScriptBlock = $SB 
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 12. Rolling forward to Snapshot2
$Snap2 = Get-VMSnapshot -VMName PSdirect -Name Snapshot2
Restore-VMSnapshot -VMSnapshot $Snap2 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 13. Observe the files you now have supporting PSDirect
$SB = {
    Get-ChildItem -Path C:\ | Format-Table
}
$ICHT = @{
  VMName      = 'PSDirect'
  ScriptBlock = $SB 
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 14. Restoring to Snapshot1 again
$Snap1 = Get-VMSnapshot -VMName PSDirect -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name PSDirect
Wait-VM -For IPAddress -Name PSDirect

# 15. Checking checkpoints and VM data files again
Get-VMSnapshot -VMName PSDirect
Get-ChildItem -Path $Parent | Format-Table

# 16. Removing all the checkpoints from HV1
Get-VMSnapshot -VMName PSDirect |
  Remove-VMSnapshot

# 17. Checking VM data files again
Get-ChildItem -Path $Parent