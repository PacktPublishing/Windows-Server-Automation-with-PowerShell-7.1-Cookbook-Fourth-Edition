# 13.7 - Remoting with PowerShell

# Run on SRV1

# 1. Defining key variables
$RgName  = 'packt_rg'         # resource group name
$NSGName = 'packt_nsg'        # NSG name
$IPName  = 'Packt_IP1'        # Private IP Address name
$User    = 'AzureAdmin'       # User Name
$UserPS  = 'JerryRocks42!'    # User Password
$PassSS  = $UserPS | ConvertTo-SecureString -Force -AsPlainText
$VMname  = 'Packt42VM'        # VM Name
$VMCred  = [pscredential]::new( ("$VMname\$User"),$PassSS)
         

# 2. Logging in to Azure
$CredAZ = Get-Credential     # Enter your Azure Credential details
$Account = Connect-AzAccount -Credential $CredAZ 

# 3. Adding NSG Rulesd for HTTPS, HTTP inbound to WinRM
$RCHT1 = @{
  Name                     = 'AllowWinRMHTTPS'
  Description              = 'Enable PowerShell Remote Access'
  Access                   = 'Allow'
  Protocol                 = 'Tcp' 
  Direction                = 'Inbound' 
  Priority                 = 110
  SourceAddressPrefix      = 'Internet'
  SourcePortRange          = '*'
  DestinationAddressPrefix = '*'
  DestinationPortRange     = 5986 
}
Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RgName | 
  Add-AzNetworkSecurityRuleConfig @RCHT1 |
    Set-AzNetworkSecurityGroup
$RCHT2 = @{
  Name                     = 'AllowWinRMHTTP'
  Description              = 'Enable PowerShell Remote Access'
  Access                   = 'Allow'
  Protocol                 = 'Tcp' 
  Direction                = 'Inbound' 
  Priority                 = 112
  SourceAddressPrefix      = 'Internet'
  SourcePortRange          = '*'
  DestinationAddressPrefix = '*'
  DestinationPortRange     = 5985 
}
Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RgName | 
  Add-AzNetworkSecurityRuleConfig @RCHT2 |
   Set-AzNetworkSecurityGroup

# 4. Create script in VM to add firewall filters
$Content = "winrm qc /force
netsh advfirewall firewall add rule name= WinRMHTTP dir=in action=allow protocol=TCP localport=5985
netsh advfirewall firewall add rule name= WinRMHTTPS dir=in action=allow protocol=TCP localport=5986"
Add-Content C:\Foo\EnableFWRule.ps1 $Content

# 5. Rnning script inside VM
Invoke-AzVMRunCommand -ResourceGroupName $RgName -Name $VMName -CommandId 'RunPowerShellScript' -ScriptPath C:\Foo\EnableFWRule.ps1

# 6. Discovering VM FQDN
$IP = Get-AzPublicIpAddress -Name $IPName
$Hostname = $IP.DnsSettings.Fqdn

# 7. Creating a remoting session
$NSHT = @{
  ComputerName = $Hostname
  Credential   = $VMCred
}
$S = New-PSSession @nsht

# 8. Run a command in the session
$SB = {hostname;whoami}
Invoke-Command -Session $s -Scriptblock $SB