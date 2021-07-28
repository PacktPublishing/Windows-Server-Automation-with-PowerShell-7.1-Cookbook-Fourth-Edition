# Recipe 12.6 - Configuring Networking
#
# Run on HV1

# 1. Setting the PSDirect VM's NIC
Get-VM PSDirect |
  Set-VMNetworkAdapter -MacAddressSpoofing On
  
# 2. Getting NIC details and any IP addresses from the PSDirect VM
Get-VMNetworkAdapter -VMName PSDirect

# 3. Creating a credential then getting VM networking details
$RKAn = 'localhost\Administrator'
$PS = 'Pa$$w0rd'
$RKP = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T = 'System.Management.Automation.PSCredential'
$RKCred = New-Object -TypeName $T -ArgumentList $RKAn, $RKP
$VMHT = @{
    VMName      = 'PSDirect'
    ScriptBlock = {Get-NetIPConfiguration | Format-Table }
    Credential  = $RKCred
}
Invoke-Command @VMHT | Format-List

# 4. Creating a virtual switch on HV1
$VSHT = @{
    Name           = 'External'
    NetAdapterName = 'Ethernet'
    Notes          = 'Created on HV1'
}
New-VMSwitch @VSHT

# 5. Connecting the PSDirect VM's NIC to the External sswitch
Connect-VMNetworkAdapter -VMName PSDirect -SwitchName External

# 6. Viewing VM networking information
Get-VMNetworkAdapter -VMName PSDirect

# 7. Observing the IP address in the PSDirect VM
$NCHT = @{
    VMName      = 'PSDirect'
    ScriptBlock = {Get-NetIPConfiguration}
    Credential  = $RKCred
}
Invoke-Command @NCHT

# 8. Viewing the hostname on PSDirect
#    Reuse the hash table from step 6
$NCHT.ScriptBlock = {hostname}
Invoke-Command @NCHT

# 9. Changing the name of the host in the PSDirect VM
#    Reuse the hash table from steps 6,7
$NCHT.ScriptBlock = {Rename-Computer -NewName Wolf -Force}
Invoke-Command @NCHT

# 10. Rebooting and wait for the restarted POSDirect VM
Restart-VM -VMName PSDirect -Wait -For IPAddress -Force

# 11. Getting hostname of the PSDirect VM
$NCHT.ScriptBlock = {HOSTNAME}
Invoke-Command @NCHT