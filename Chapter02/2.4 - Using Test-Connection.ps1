# 2.4 - Using Test-Connection
#
# Run on SRV1 after installing PowerShell 7

# 1. Using Test-Connection with the -TargetName parameter
Test-Connection -TargetName www.packt.com -Count 1

# 2. Using Test-Connection with an IPv4 address
Test-Connection -TargetName www.packt.com -Count 1 -IPv4

# 3. Using Resolve-DnsName to resolve destination address
$IPs = (Resolve-DnsName -Name Dns.Google -Type A).IPAddress
$IPs | 
  Test-Connection -Count 1 -ResolveDestination

# 4. Resolving destination and trace route
Test-Connection -TargetName 8.8.8.8 -ResolveDestination -Traceroute |
  Where-Object Ping -eq 1

# 5. Using infinite pPing and stopping with Ctrl-C
Test-Connection -TargetName www.reskit.net -Repeat

# 6. Checking speed of Test-Connection in PowerShell 7
Measure-Command -Expression {
  Test-Connection -TargetName  8.8.8.8 -count 1}

# 7. Checking speed of Test-Connection in Windows PowerShell
$Session = New-PSSession -UseWindowsPowerShell
Invoke-Command -Session $Session -Scriptblock {
    Measure-Command -Expression {
      Test-Connection -ComputerName 8.8.8.8 -Count 1}
}
