# 7.1 - Configuring IP asddressing

# Run this code on SRV2 after creation

# 1. Discovering the adapter, adapter interface and adapter interface index
$IPType    = 'IPv4'
$Adapter   = Get-NetAdapter |  Where-Object Status -eq 'Up'     
$Interface = $Adapter | Get-NetIPInterface -AddressFamily $IPType
$Index     = $Interface.IfIndex
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table -Property Interface*, IPAddress, PrefixLength

# 2. Setting a new IP address for the NIC
$IPHT = @{
  InterfaceIndex = $Index
  PrefixLength   = 24
  IPAddress      = '10.10.10.52'
  DefaultGateway = '10.10.10.254'
  AddressFamily  = $IPType
}
New-NetIPAddress @IPHT

# 3. Verifying the new IP address
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table IPAddress, InterfaceIndex, PrefixLength

# 4. Setting DNS Server IP address
$CAHT = @{
  InterfaceIndex  = $Index
  ServerAddresses = '10.10.10.10'
}
Set-DnsClientServerAddress @CAHT

# 5. Verifying the new IP configuration
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table

# 6. Testing that SRV2 can see the domain controller
Test-NetConnection -ComputerName DC1.Reskit.Org |
  Format-Table

# 7. Creating a credential for DC1
$U    = 'Reskit\Administrator'
$PPT  = 'Pa$$w0rd'
$PSS  = ConvertTo-SecureString -String $ppt -AsPlainText -Force
$Cred = [pscredential]::new($U,$PSS)

# 8. Setting WinRM on SRV1 to trust DC1
$TPPATH = 'WSMan:\localhost\Client\TrustedHosts'
Set-Item -Path $TPPATH -Value 'dc1' -Force
Restart-Service -Name WinRM -Force

# 9. Enabling non-secure updates to Reskit.Org DNS domain
$DNSSSB = {
  $SBHT = @{
    Name          = 'Reskit.Org'
    DynamicUpdate = 'NonsecureAndSecure'
  }
  Set-DnsServerPrimaryZone @SBHT
}
Invoke-Command -ComputerName DC1 -ScriptBlock $DNSSSB -Credential $Cred

# 10. Ensuring host registers within the Reskit.Org DNS zone
$DNSCHT = @{
  InterfaceIndex                 = $Index
  ConnectionSpecificSuffix       = 'Reskit.Org'
  RegisterThisConnectionsAddress = $true
  UseSuffixWhenRegistering       = $true
}
Set-DnsClient  @DNSCHT

# 11. Registering host IP address at DC1
Register-DnsClient 

# 12. Pre-staging SRV2 in AD
$SB = {New-ADComputer -Name SRV2}
Invoke-Command -ComputerName DC1 -ScriptBlock $SB

# 13. Testing the DNS server on DC1.Reskit.Org correctly resolves SRV2
Resolve-DnsName -Name SRV2.Reskit.Org -Type 'A' -Server DC1.Reskit.Org
  