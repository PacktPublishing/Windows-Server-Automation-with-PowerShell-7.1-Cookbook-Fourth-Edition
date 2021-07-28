# 7.7 - Configuring DNS in the Enterprise

# Run this on DC2 after promoting to DC
# Have DC1, DC2, SRV2 online

# 1. Installing the DNS feature on DC2
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name DNS -IncludeManagementTools  

# 2. Creating a script block to set DNS Server Options
$SB1 = {
  # Enable recursion on this server
  Set-DnsServerRecursion -Enable $true
  # Configure DNS Server cache maximum size
  Set-DnsServerCache  -MaxKBSize 20480  # 28 MB
  # Enable EDNS
  $EDNSHT = @{
    EnableProbes    = $true
    EnableReception = $true
  }
  Set-DnsServerEDns @EDNSHT
  # Enable Global Name Zone
  Set-DnsServerGlobalNameZone -Enable $true
}

# 3. Reconfiguring DNS on DC2, DC1
Invoke-Command -ScriptBlock $SB1
Invoke-Command -ScriptBlock $SB1 -ComputerName DC1

# 4. Creating script block to configure DC2 to have TWO DNS servers
$SB2 = {
  $NIC = 
    Get-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4
  $DNSSERVERS = ('127.0.0.1','10.10.10.10')
  $DNSHT = @{
    InterfaceIndex  = $NIC.InterfaceIndex
    ServerAddresses = $DNSSERVERS
  }
  Set-DnsClientServerAddress @DNSHT
  Start-Service -Name DNS
}

# 5. Configuring DC2 to have two DNS servers
Invoke-Command -ScriptBlock $SB2

# 6. Creating a script block to configure DC1 to have two DNS servers
$SB3 = {
  $NIC = 
    Get-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4
  $DNSSERVERS = ('127.0.0.1','10.10.10.11')
  $DNSHT = @{
    InterfaceIndex  = $NIC.InterfaceIndex
    ServerAddresses = $DNSSERVERS
  }
  Set-DnsClientServerAddress @DNSHT
  Start-Service -Name DNS
}

# 7. Configuring DCa to have two DNS servers
Invoke-Command -ScriptBlock $SB3 -ComputerName DC1

# 8. Update DHCP scope to add 2 DNS entries
$DNSOPTIONHT = @{
  DnsServer    = '10.10.10.11',
                 '10.10.10.10'    # Client DNS Servers
  DnsDomain    = 'Reskit.Org'
  Force        = $true
}
Set-DhcpServerV4OptionValue @DNSOPTIONHT -ComputerName DC1
Set-DhcpServerV4OptionValue @DNSOPTIONHT -ComputerName DC2

# 9. Getting DNS service details
$DNSRV = Get-DNSServer -ComputerName DC2.Reskit.Org

# 10. Viewing recursion settings
$DNSRV |
  Select-Object -ExpandProperty ServerRecursion

# 11. Viewing server cache settings
$DNSRV | 
  Select-Object -ExpandProperty ServerCache

# 12. Viewing ENDS Settings
$DNSRV |
  Select-Object -ExpandProperty ServerEdns

# 13. Setting Reskit.Org zone to be secure only
$DNSSSB = {
  $SBHT = @{
    Name          = 'Reskit.Org'
    DynamicUpdate = 'Secure'
  }
  Set-DnsServerPrimaryZone @SBHT
}
Invoke-Command -ComputerName DC1 -ScriptBlock $DNSSSB
Invoke-Command -ComputerName DC2 -ScriptBlock $DNSSSB

# 14. Adding SRV2 to Domain
# run on SRV2
$User  = 'Reskit\Administrator'
$Pass  = 'Pa$$w0rd'
$PSS   = $Pass | ConvertTo-SecureString -Force -AsPlainText
$CRED  = [PSCredential]::new($User,$PSS)
$Sess  = New-PSSession -UseWindowsPowerShell
Invoke-Command -Session $Sess -Scriptblock {
  $ACHT = @{
    Credential = $using:Cred 
    Domain     = 'Reskit.org' 
    Force      = $True
  }
  Add-Computer @ACHT
  Restart-Computer
} | Out-Null


