# Recipe 12.10 - Configuring VM replication

# Run on HV1, with HV2, DC1 (and DC2) online

# 1. Configuring HV1 and HV2 to be trusted for delegation in AD on DC1
$SB = {
  Set-ADComputer -Identity HV1 -TrustedForDelegation $True
  Set-ADComputer -Identity HV2 -TrustedForDelegation $True
}
Invoke-Command -ComputerName DC1 -ScriptBlock $SB

# 2. Rebooting the HV1 and HV2 hosts
Restart-Computer -ComputerName HV2 -Force
Restart-Computer -ComputerName HV1 -Force

# 3. Configuring Hyper-V replication on HV1 and HV2
$VMRHT = @{
  ReplicationEnabled              = $true
  AllowedAuthenticationType       = 'Kerberos'
  KerberosAuthenticationPort      = 42000
  DefaultStorageLocation          = 'C:\Replicas'
  ReplicationAllowedFromAnyServer = $true
  ComputerName                    = 'HV1.Reskit.Org',
                                    'HV2.Reskit.Org'
}
Set-VMReplicationServer @VMRHT

# 4. Enabling PSDirect on HV1 to be a replica source
$VMRHT = @{
  VMName             = 'PSDirect'
  Computer           = 'HV1'
  ReplicaServerName  = 'HV2'
  ReplicaServerPort  = 42000
  AuthenticationType = 'Kerberos'
  CompressionEnabled = $true
  RecoveryHistory    = 5
}
Enable-VMReplication  @VMRHT

# 5. Viewing the replication status of HV1
Get-VMReplicationServer -ComputerName HV1

# 6. Checking PSDirect on Hyper-V hosts
Get-VM -ComputerName HV1 -VMName PSDirect
Get-VM -ComputerName HV2 -VMName PSDirect

# 7. Starting the initial replication
Start-VMInitialReplication -VMName PSDirect -ComputerName HV1

# 8. Examining the initial replication state on HV1 just after
#    you start the initial replication
Measure-VMReplication -ComputerName HV1

# 9. Examining the replication status on HV1 after replication completes
Measure-VMReplication -ComputerName HV1

# 10. Testing PSDirect failover to HV2
$SB = {
  $VM = Start-VMFailover -AsTest -VMName PSDirect -Confirm:$false
  Start-VM $VM
}
Invoke-Command -ComputerName HV2 -ScriptBlock $SB

# 11. Viewing the status of PSDirect VMs on HV2
Get-VM -ComputerName HV2 -VMName PSDirect*

# 12. Stopping the failover test
$SB = {
  Stop-VMFailover -VMName PSDirect
}
Invoke-Command -ComputerName HV2 -ScriptBlock $SB

# 13. Viewing the status of VMs on HV1 and HV2 after failover stopped
Get-VM -ComputerName HV1
Get-VM -ComputerName HV2

# 14. Stopping VM1 on HV1 before performing a planned failover
Stop-VM PSDirect -ComputerName HV1

# 15. Starting VM failover from HV1 to HV2
Start-VMFailover -VMName PSDirect -ComputerName HV2 -Confirm:$false

# 16. Completing the failover
$CHT = @{
  VMName       = 'PSDIrect'
  ComputerName = 'HV2'
  Confirm      = $false
}
Complete-VMFailover @CHT

# 17. Starting the replicated VM on HV2
Start-VM -VMname PSDirect -ComputerName HV2
Set-VMReplication -VMname PSDirect -reverse -ComputerName HV2

# 18. Checking the PSDirect VM on HV1 and HV2 after the planned failover
Get-VM -ComputerName HV1 -Name PSDirect
Get-VM -ComputerName HV2 -Name PSDirect

# 19. Removing the VM replication on HV1
Remove-VMReplication -VMName PSDirect -ComputerName HV2

# 20. Removing the PSDirect VM replica on HV1
Remove-VM -Name PSDirect -ComputerName HV1 -Confirm:$false -Force

# Run remainder of this recipe on HV2

# 21. Moving the PSDirect VM back to HV1
$VMHT2 = @{
    Name                  = 'PSDirect'
    ComputerName           = 'HV2'
    DestinationHost        = 'HV1'
    IncludeStorage         =  $true
    DestinationStoragePath = 'C:\VM\VHDS\PSDirect' # on HV1
}
Move-VM @VMHT2

