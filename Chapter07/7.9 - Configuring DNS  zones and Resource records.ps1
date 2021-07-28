# 4.7 Configuring DNS Zones and Resource Records 

# Run on DC1 after building the domain

# 1. Creating a new primary forward DNS zone for Cookham.Net
$ZHT1 = @{
  Name              = 'Cookham.Net'
  ResponsiblePerson = 'dnsadmin.cookham.net.' 
  ReplicationScope  = 'Forest'
  ComputerName      = 'DC1.Reskit.Org'
}
Add-DnsServerPrimaryZone @ZHT1

# 2. Creating a reverse lookup zone
$ZHT2 = @{
  NetworkID         = '10.10.10.0/24'
  ResponsiblePerson = 'dnsadmin.reskit.org.' 
  ReplicationScope  = 'Forest'
  ComputerName      = 'DC1.Reskit.Org'
}
Add-DnsServerPrimaryZone @ZHT2

# 3. Registering DNS for DC1, DC2 
Register-DnsClient
Invoke-Command -ComputerName DC2 -ScriptBlock {Register-DnsClient}

# 4. Checking the DNS zones on DC1
Get-DNSServerZone -ComputerName DC1

# 5. Adding Resource Records to Cookham.Net zone
# Adding an A record
$RRHT1 = @{
  ZoneName      =  'Cookham.Net'
  A              =  $true
  Name           = 'Home'
  AllowUpdateAny =  $true
  IPv4Address    = '10.42.42.42'
}  
Add-DnsServerResourceRecord @RRHT1
# Adding a Cname record
$RRHT2 = @{
  ZoneName      = 'Cookham.Net'
  Name          = 'MAIL'
  HostNameAlias = 'Home.Cookham.Net'
}
Add-DnsServerResourceRecordCName @RRHT2
# Adding an MX record
$MXHT = @{
  Preference     = 10 
  Name           = '.'
  TimeToLive     = '4:00:00'
  MailExchange   = 'Mail.Cookham.Net'
  ZoneName       = 'Cookham.Net'
}
Add-DnsServerResourceRecordMX @MXHT

# 6. Restarting DNS Service to ensure replication
Restart-Service -Name DNS
$SB = {Restart-Service -Name DNS}
Invoke-Command -ComputerName DC2 -ScriptBlock $SB

# 7. Checking results of RRs in Cookham.Net zone
Get-DnsServerResourceRecord -ZoneName 'Cookham.Net'

# 8. Testing DNS resolution on DC2, DC1
# Testing The CNAME from DC1
Resolve-DnsName -Server DC1.Reskit.Org -Name 'Mail.Cookham.Net'
# Testing the MX on DC2
Resolve-DnsName -Server DC2.Reskit.Org -Name 'Cookham.Net'

# 9. Testing the reverse lookup zone
Resolve-DnsName -Name '10.10.10.10'
