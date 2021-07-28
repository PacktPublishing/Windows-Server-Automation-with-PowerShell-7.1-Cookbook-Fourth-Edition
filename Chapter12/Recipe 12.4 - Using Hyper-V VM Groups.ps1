# Recipe 12.4 - Using Hyper-V VM Groups
#
# Run on HV2


# 1. Creating VMs on HV2
$VMLocation  = 'C:\Vm\VMs'   # Created in earlier recipe
# Create SQLAcct1
$VMN1        = 'SQLAcct1'
New-VM -Name $VMN1 -Path "$VMLocation\$VMN1"
# Create SQLAcct2
$VMN2        = 'SQLAcct2'
New-VM -Name $VMN2 -Path "$VMLocation\$VMN2"
 # Create SQLAcct3
$VMN3        = 'SQLAcct3'
New-VM -Name $VMN3 -Path "$VMLocation\$VMN3"
# Create SQLMfg1
$VMN4        = 'SQLMfg1'
New-VM -Name $VMN4 -Path "$VMLocation\$VMN4"
# Create SQLMfg2
$VMN5        = 'SQLMfg2'
New-VM -Name $VMN5 -Path "$VMLocation\$VMN5"

# 2. Viewing SQL VMs
Get-VM -Name SQL*

# 3. Creating Hyper-V VM groups
$VHGHT1 = @{
  Name      = 'SQLAccVMG'
  GroupType = 'VMCollectionType'
}
$VMGroupACC = New-VMGroup @VHGHT1
$VHGHT2 = @{
  Name      = 'SQLMfgVMG'
  GroupType = 'VMCollectionType'
}
$VMGroupMFG = New-VMGroup @VHGHT2

# 4. Displaying the VM groups on HV2
Get-VMGroup | 
  Format-Table -Property Name, *Members, ComputerName 

# 5. Creating arrays of group member VM names
$ACCVMs = 'SQLAcct1', 'SQLAcct2','SQLAcct3'
$MFGVms = 'SQLMfg1', 'SQLMfg2'

# 6. Adding members to the Accounting SQL VM group
Foreach ($Server in $ACCVMs) {
    $VM = Get-VM -Name $Server
    Add-VMGroupMember -Name SQLAccVMG -VM $VM
}

# 7. Adding members to the Manufacturing SQL VM group
Foreach ($Server in $MfgVMs) {
    $VM = Get-VM -Name $Server
    Add-VMGroupMember -Name SQLMfgVMG -VM $VM
}
# 8. Viewing VM groups on HV2
Get-VMGroup |                                     
 Format-Table -Property Name, *Members, ComputerName

# 9. Creating a management collection VMG group
$VMGHT = @{
  Name      = 'VMMGSQL'
  GroupType = 'ManagementCollectionType'
}
$VMMGSQL = New-VMGroup  @VMGHT

# 10. Adding the two VMCollectionType groups to the VMManagement group
Add-VMGroupMember -Name VMMGSQL -VMGroupMember $VMGroupACC,
                                               $VMGroupMFG

# 11. Setting FormatEnumerationLimit to 99
$FormatEnumerationLimit = 99

# 12. Viewing VM groups by type
Get-VMGroup | Sort-Object -Property GroupType |
  Format-Table -Property Name, GroupType, VMGroupMembers,
                         VMMembers 

# 13. Stopping all the SQL VMs
Foreach ($VM in ((Get-VMGroup VMMGQL).VMGroupMembers.vmmembers)) {
  Stop-VM -Name $vm.name -WarningAction SilentlyContinue
}

# 14. Setting CPU count in all SQL VMs to 4
Foreach ($VM in ((Get-VMGroup VMMGSQL).VMGroupMembers.VMMembers)) {
  Set-VMProcessor -VMName $VM.name -Count 4
}

# 15. Setting Accounting SQL VMs to have 6 processors
Foreach ($VM in ((Get-VMGroup SQLAccVMG).VMMembers)) {
  Set-VMProcessor -VMName $VM.name -Count 6
}

# 16. Checking processor counts for all VMs sorted by CPU count
$VMS = (Get-VMGroup -Name VMMGSQL).VMGroupMembers.VMMembers
Get-VMProcessor -VMName $VMS.Name | 
  Sort-Object -Property Count -Descending |
    Format-Table -Property VMName, Count

# 17. Remove VMs from VM groups
$VMs = (Get-VMGroup -Name SQLAccVMG).VMMEMBERS
Foreach ($VM in $VMS)  {
  $X = Get-VM -vmname $VM.name
  Remove-VMGroupMember -Name SQLAccVMG -VM $x
  }
$VMs = (Get-VMGroup -Name SQLMFGVMG).VMMEMBERS
Foreach ($VM in $VMS)  {
  $X = Get-VM -vmname $VM.name
  Remove-VMGroupMember -Name SQLmfgvMG -VM $x
}

# 18. Removing VMGrouwps from VMManagementGroups
$VMGS = (Get-VMGroup -Name VMMGSQL).VMMembers
Foreach ($VMG in $VMGS)  {
  $X = Get-VMGroup -vmname $VMG.name
  Remove-VMGroupMember -Name VMMGSQL -VMGroupName $x
}

# 19. Removing all the VMGroups
Remove-VMGroup -Name SQLACCVMG -Force
Remove-VMGroup -Name SQLMFGVMG -Force
Remove-VMGroup -Name VMMGSQL   -Force