# 14.4 Network Troubleshooting

# Run on SRV1


# 1. Getting the DNS name of this host
$DNSDomain = $Env:USERDNSDOMAIN
$FQDN      = "$Env:COMPUTERNAME.$DNSDomain"

# 2. Getting DNS server address
$DNSHT = @{
  InterfaceAlias = "Ethernet"
  AddressFamily  = 'IPv4'
}
$DNSServers = (Get-DnsClientServerAddress @DNSHT).ServerAddresses
$DNSServers

# 3. Checking if the DNS servers are online
Foreach ($DNSServer in $DNSServers) {
  $TestDNS = Test-NetConnection -Port 53 -ComputerName $DNSServer   
  $Result  = $TestDNS ? "Available" : ' Not reachable'
  "DNS Server [$DNSServer] is $Result"
}

# 4. Defining a search for DCs in our domain
$DNSRRName = "_ldap._tcp." + $DNSDomain
$DNSRRName

# 5. Getting the DC SRV records
$DCRRS = Resolve-DnsName -Name $DNSRRName -Type all | 
    Where-Object IP4address -ne $null
$DCRRS

# 6. Testing each DC for availability over LDAP
ForEach ($DNSRR in $DCRRS){
  $TestDC = Test-NetConnection -Port 389 -ComputerName $DNSRR.IPAddress
  $Result  = $TestDC ? 'DC Available' : 'DC Not reachable'
  "DC [$($DNSRR.Name)]  at [$($DNSRR.IPAddress)]   $Result for LDAP" 
}

# 7. Testing DC availability for SMB
ForEach ($DNSRR in $DCRRS){
  $TestDC = Test-NetConnection -Port 445 -ComputerName $DNSRR.IPAddress
  $Result  = $TestDC ? 'DC Available' : 'DC Not reachable'
  "DC [$($DNSRR.Name)]  at [$($DNSRR.IPAddress)]   $Result for SMB"
}

# 8. Testing default gateway
$NIC    = Get-NetIPConfiguration -InterfaceAlias Ethernet
$DG     = $NIC.IPv4DefaultGateway.NextHop
$TestDG = Test-NetConnection $DG
$Result  = $TestDG.PingSucceeded ? "Reachable" : ' NOT Reachable'
"Default Gateway for [$($NIC.Interfacealias) is [$DG] - $Result"

# 9. Testing a remote web site using ICMP
$Site = "WWW.Packt.Com"
$TestIP     = Test-NetConnection -ComputerName $Site
$ResultIP   = $TestIP ? "Ping OK" : "Ping FAILED" 
"ICMP to $Site - $ResultIP"

# 10. Testing a remote web site using port 80
$TestPort80 = Test-Connection -ComputerName $Site -TcpPort 80
$Result80    = $TestPort80  ? 'Site Reachable' : 'Site NOT reachable'
"$Site over port 80   : $Result80"

# 11. Testing a remote web site using port 443
$TestPort443 = Test-Connection -ComputerName $Site -TcpPort 443
$Result443   = $TestPort443  ? 'Site Reachable' : 'Site NOT reachable'
"$Site over port 443  : $Result443"
