# 6.9 Reporting on Managing AD Replication

# run on DC1, with DC2, UKDC1 up and running

# 1. Checking replication partners for DC1
Get-ADReplicationPartnerMetadata -Target DC1.Reskit.Org   | 
  Format-List -Property Server, PartnerType, Partner, 
                        Partition, LastRep* 

# 2. Checking AD replication partner metadata in the domain                  
Get-ADReplicationPartnerMetadata -Target Reskit.Org -Scope Domain |
  Format-Table -Property Server, P*Type, Last*

# 3. Investigating group membership metadata
$REPLHT = @{
  Object              = (Get-ADGroup -Identity 'IT Team')
  Attribute           = 'Member'
  ShowAllLinkedValues = $true
  Server              = (Get-ADDomainController)
}
Get-ADReplicationAttributeMetadata @REPLHT |
  Format-Table -Property A*NAME, A*VALUE, *TIME

# 4. Adding two users to the group and removing one
Add-ADGroupMember -Identity 'IT Team' -members Malcolm
Add-ADGroupMember -Identity 'IT Team' -members Claire
Remove-ADGroupMember -Identity 'IT Team' -members Claire -Confirm:$False

# 5 Checking updated metadata
Get-ADReplicationAttributeMetadata @REPLHT |
  Format-Table -Property A*NAME,A*VALUE, *TIME

# 6. Creating an initial replication failure report
$DomainController = 'DC1'
$Report = [ordered] @{}
## Replication Partners ##
$ReplMeta = 
    Get-ADReplicationPartnerMetadata -Target $DomainController
$Report.ReplicationPartners = $ReplMeta.Partner
$Report.LastReplication     = $ReplMeta.LastReplicationSuccess
## Replication Failures ##
$REPLF = Get-ADReplicationFailure -Target $DomainController
$Report.FailureCount  = $REPLF.FailureCount
$Report.FailureType   = $REPLF.FailureType
$Report.FirstFailure  = $REPLF.FirstFailureTime
$Report.LastFailure   = $REPLF.LastFailure
$Report 

# 7 Simulating a connection issue
Stop-Computer DC2  -Force
Start-Sleep -Seconds 30

# 8.  Making a change to this AD
Get-AdUser -identity BillyBob  | 
  Set-AdUser -Office 'Cookham Office' -Server DC1

# 9. Using Repadmin to generate a status report
repadmin /replsummary

