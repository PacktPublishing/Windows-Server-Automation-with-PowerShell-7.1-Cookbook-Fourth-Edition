# 7.8 - Configure DNS Forwarding

# Run On DC1

# 1.Obtaining the IP aAddresses of DNS servers for packt.com
$NS = Resolve-DnsName -Name packt.Com -Type NS | 
  Where-Object Name -eq 'packt.com'
$NS

# 2.Obtaining the IPV4 addresses for these hosts
$NSIPS = foreach ($Server in $NS) {
  (Resolve-DnsName -Name $Server.NameHost -Type A).IPAddress
}
$NSIPS

# 3. Adding conditional forwarder on DC1
$CFHT = @{
  Name          = 'Packt.Com'
  MasterServers = $NSIPS
}
Add-DnsServerConditionalForwarderZone @CFHT

# 4. Checking zone on DC1 
Get-DnsServerZone -Name Packt.Com

# 5. Testing conditional forwarding
Resolve-DNSName -Name WWW.Packt.Com -Server DC1 |
 Format-Table 