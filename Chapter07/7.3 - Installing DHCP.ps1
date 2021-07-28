# 7.3 - Instal and Authorize DC1 as a DHCP server
#
# Run on DC1 after AD setup 

# 1. Installing the DHCP feature on DC1 and add the management tools
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# 2. Adding DC1 to trusted DHCP servers and add the DHCP security group
Import-Module -Name DHCPServer -WarningAction SilentlyContinue
Add-DhcpServerInDC
Add-DHCPServerSecurityGroup 

# 3. Letting DHCP know it's all configured
$DHCPHT = @{
  Path  = 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12'
  Name  = 'ConfigurationState'
  Value = 2
}
Set-ItemProperty @DHCPHT

# 4. Restarting DHCP server 
Restart-Service -Name DHCPServer -Force 

# 5. Testing service availability
Get-Service -Name DHCPServer | 
  Format-List -Property *