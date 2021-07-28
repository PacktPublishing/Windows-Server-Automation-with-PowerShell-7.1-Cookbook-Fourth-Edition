# Recipe 12.7 - Implementing nested virtualization
#
# Run on HV1

#  1. Stopping the PSDirect VM
Stop-VM -VMName PSDirect

# 2. Setting the VM's processor to support virtualization
$VMHT = @{
  VMName                         = ‘PSDirect’ 
  ExposeVirtualizationExtensions = $true
}
Set-VMProcessor @VMHT
Get-VMProcessor -VMName PSDirect |
  Format-Table -Property Name, Count,
                         ExposeVirtualizationExtensions

# 3. Starting the PSDirect VM
Start-VM -VMName PSDirect
Wait-VM  -VMName PSDirect -For Heartbeat
Get-VM   -VMName PSDirect

# 4. Creating credentials for PSDirect
$User = 'Wolf\Administrator'  
$PHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$PSS  = ConvertTo-SecureString @PHT
$Type = 'System.Management.Automation.PSCredential'
$CredRK = New-Object -TypeName $Type -ArgumentList $User, $PSS

# 5. Creating a script block for remote execution
$SB = {
  Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
}

# 6. Creating a remoting session to PSDirect
$Session = New-PSSession -VMName PSDirect -Credential $CredRK

# 7. Installing Hyper-V inside PSDirect
$IHT = @{
  Session     = $Session
  ScriptBlock = $SB 
}
Invoke-Command @IHT

# 8. Restarting the VM to finish adding Hyper-V to PSDirect
Stop-VM  -VMName PSDirect
Start-VM -VMName PSDirect
Wait-VM  -VMName PSDirect -For IPAddress
Get-VM   -VMName PSDirect

# 9. Creating a nested VM inside the PSDirect VM
$SB2 = {
        $VMname = 'NestedVM'
        New-VM -Name $VMname -MemoryStartupBytes 1GB | Out-Null
        Get-VM
}
$IHT2 = @{
  VMName = 'PSDirect'
  ScriptBlock = $SB2
}
Invoke-Command @IHT2 -Credential $CredRK

