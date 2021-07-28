# 7.6 - Configuring DHCP Load Balancing and Failover

# Run on DC2 after setting DC1 up as a DHCP Server 
# And with and a Scope defined

# 1. Installing the DHCP server feature on DC2
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$FEATUREHT = @{
  Name                   = 'DHCP'
  IncludeManagementTools = $True
}
Install-WindowsFeature @FEATUREHT

# 2. Letting DHCP know it is fully configured
$IPHT = @{
  Path  = 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12'
  Name  = 'ConfigurationState'
  Value = 2
}
Set-ItemProperty @IPHT

# 3. Authorizing the DHCP server in AD
Import-Module -Name DHCPServer -WarningAction 'SilentlyContinue'
Add-DhcpServerInDC -DnsName DC2.Reskit.Org

# 4. Viewing authorized DHCP servers in the Reskit domain
Get-DhcpServerInDC

# 5. Configuring fail-over and load balancing
$FAILOVERHT = @{
  ComputerName       = 'DC1.Reskit.Org'
  PartnerServer      = 'DC2.Reskit.Org'
  Name               = 'DC1-DC2'
  ScopeID            = '10.10.10.0'
  LoadBalancePercent = 60
  SharedSecret       = 'j3RryIsTheB3est!'
  Force              = $true
  Verbose            = $True
}
Invoke-Command -ComputerName DC1.Reskit.Org -ScriptBlock {
  Add-DhcpServerv4Failover @Using:FAILOVERHT  
}

# 6. Getting active leases in the scope (from both servers!)
$DHCPServers = 'DC1.Reskit.Org', 'DC2.Reskit.Org' 
$DHCPServers |   
  ForEach-Object { 
    "Server $_" | Format-Table
    Get-DhcpServerv4Scope -ComputerName $_ | Format-Table
  }

# 7. Viewing DHCP server statistics from both DHCP Servers
$DHCPServers |
  ForEach-Object {
    "Server $_" | Format-Table
    Get-DhcpServerv4ScopeStatistics -ComputerName $_  | Format-Table
  } 
