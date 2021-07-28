#  Recipe 13.6 - Creating an Azure VM
#
# Run on SRV1

# 1. Defining key variables
$Locname = 'uksouth'          # location name
$RgName  = 'packt_rg'         # resource group name
$SAName  = 'packt42sa'        # Storage account name
$VNName  = 'packtvnet'        # Virtual Network Name
$CloudSN = 'packtcloudsn'     # Cloud subnet name
$NSGName = 'packt_nsg'        # NSG name
$Ports   = @(80, 3389, 5985)  # ports to open in VPN
$IPName  = 'Packt_IP1'        # Private IP Address name
$User    = 'AzureAdmin'       # User Name
$UserPS  = 'JerryRocks42!'    # User Password
$VMName  = 'Packt42VM'        # VM Name

#  2. Logging into your Azure account
$Account = Connect-AzAccount

# 3. Getting the resource group is created
$RG = Get-AzResourceGroup -Name $RgName 

# 4. Getting the Storage Account
$SA = Get-AzStorageAccount -Name $SAName -ResourceGroupName $RgName

# 5.  Creating VM credentials
$T      = 'System.Management.Automation.PSCredential'
$P      = ConvertTo-SecureString -String $UserPS -AsPlainText -Force
$VMCred = [PSCredential]::New($User, $P)

# 6. Creating a simple VM using defaults
$VMHT = @{
    ResourceGroupName   = $RgName
    Location            = $Locname 
    Name                = $VMName
    VirtualNetworkName  = $VNName
    SubnetName          = $CloudSN
    SecurityGroupName   = $NSGName
    PublicIpAddressName = $IPName
    OpenPorts           = $Ports
    Credential          = $VMCred
}
New-AzVm @VMHT 

# 7. Getting the VM's External IP address
$VMIP = Get-AzPublicIpAddress -ResourceGroupName $RGname  
$VMIP = $VMIP.IpAddress
"VM Public IP Address: [$VMIP]"

# 8. Connecting to the VM
mstsc /v:"$VMIP"

# 9. Tidying up - stopping and removing the Azure VM
Stop-AzVm -Name $VMName -Resourcegroup $RgName -Force |
  Out-Null
Remove-AZVm -Resourcegroup $RgName -Name $VMName -Force |
  Out-Null

# 10. Tidying up - Removing VM's networking artifacts
Remove-AzNetworkInterface -Resourcegroup $RgName -Name $VMName -Force
Remove-AzPublicIpAddress -Resourcegroup $RgName -Name $IPName -Force
Remove-AzNetworkSecurityGroup -Resourcegroup $RgName -Name $NSGName -Force
Remove-AzVirtualNetwork -Name $VNName -Resourcegroup $RgName -Force
Get-AzNetworkWatcher | Remove-AzNetworkWatcher
Get-AzResourceGroup -Name NetworkWatcherRG  | 
  Remove-AzResourceGroup -Force |
    Out-Null

# 11. Tidying up - Removing the VM's disk
Get-AzDisk | Where-Object name -match "packt42vm" | 
  Remove-AzDisk -Force |
    Out-Null

# 12. Tidying Up - Removing the storage account and resource group
$RHT = @{
  StorageAccountName = $SAName 
  ResourceGroupName  = $RgName 
}
Get-AzStorageAccount @RHT |
  Remove-AzStorageAccount -Force
Get-AzResourceGroup -Name $RgName |
  Remove-AzResourceGroup -Force
    Out-Null






# For winrm testing
# Remember:
$User    = 'AzureAdmin'       # User Name
$UserPS  = 'JerryRocks42!'    # User Password
$VMName  = 'Packt42VM'        # VM Name

$VMU = "$VMNAME\$User" # VM user name
$PWSS = $UserPS | ConvertTo-SecureString -AsPlainText -Force
$Cred = [pscredential]::new($VMU,$PWSS)
$SO = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Enter-PSSession -ConnectionUri ("http://$VMIP" + ":5985") -Credential $cred -SessionOption $SO

