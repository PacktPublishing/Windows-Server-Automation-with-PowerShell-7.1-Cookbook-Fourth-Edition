# 7.5 Using DHCP 

# Run on SRV2 after you have installed and configured DHCP Server on DC1.
# SRV2 remains a workgroup server.

# 1. Adding DHCP RSAT tools
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name RSAT-DHCP 

# 2. Importing the DHCP module
Import-Module -Name DHCPServer -WarningAction SilentlyContinue

# 3. Viewing the scopes on DC1
Get-DhcpServerv4Scope -ComputerName DC1

# 4. Getting V4 scope statistics from DC1
Get-DhcpServerv4ScopeStatistics -ComputerName DC1

# 5. Discovering a free IP address
Get-DhcpServerv4FreeIPAddress -ComputerName dc1 -ScopeId 10.10.10.42

# 6. Getting SRV2 NIC Configuration
$NIC = Get-NetIPConfiguration -InterfaceAlias 'Ethernet'

# 7. Getting IP interface
$NIC | 
  Get-NetIPInterface  | 
    Where-Object AddressFamily -eq 'IPv4'

# 8. Enabling DHCP on the NIC
$NIC | 
  Get-NetIPInterface  | 
    Where-Object AddressFamily -eq 'IPv4' |
      Set-NetIPInterface -Dhcp Enabled

# 9. Checking IP address assigned
Get-NetIPAddress -InterfaceAlias "Ethernet"  | 
  Where-Object AddressFamily -eq 'IPv4'

# 10. Getting updated V4 scope statistics from DC1
Get-DhcpServerv4ScopeStatistics -ComputerName DC1

# 11. Discovering the next free IP address
Get-DhcpServerv4FreeIPAddress -ComputerName dc1 -ScopeId 10.10.10.42

# 12. Checking IPv4 DNS name resolution 
Resolve-DnsName -Name SRV2.reskit.org -Type A








