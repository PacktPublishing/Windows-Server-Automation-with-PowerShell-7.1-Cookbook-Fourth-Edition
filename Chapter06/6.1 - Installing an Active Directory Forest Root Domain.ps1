# 6.1 - Installing an Active Directory Forest Root Domain  

# This recipe uses DC1 
# DC1 is initially a stand-alone work group server you convert
# into a DC with DNS.

# 1. Installing the AD Domain Services feature and management tools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 2. Importing the ADDeployment module
Import-Module -Name ADDSDeployment 

# 3. Examining the commands in the ADDSDeployment module
Get-Command -Module ADDSDeployment

# 4.	Creating a secure password for Administrator
$PSSHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$PSS = ConvertTo-SecureString @PSSHT

# 5. Testing DC Forest installation starting on DC1
$FOTHT = @{
  DomainName           = 'Reskit.Org'
  InstallDNS           = $true 
  NoRebootOnCompletion = $true
  SafeModeAdministratorPassword = $PSS
  ForestMode           = 'WinThreshold'
  DomainMOde           = 'WinThreshold'
}
Test-ADDSForestInstallation @FOTHT -WarningAction SilentlyContinue

# 6. Creating Forest Root DC on DC1
$ADHT = @{
  DomainName                    = 'Reskit.Org'
  SafeModeAdministratorPassword = $PSS
  InstallDNS                    = $true
  DomainMode                    = 'WinThreshold'
  ForestMode                    = 'WinThreshold'
  Force                         = $true
  NoRebootOnCompletion          = $true
  WarningAction                 = 'SilentlyContinue'
}
Install-ADDSForest @ADHT

# 7. Checking key AD and related services
Get-Service -Name DNS, Netlogon

# 8. Checking DNS zones
Get-DnsServerZone

# 9. Restarting DC1 to complete promotion
Restart-Computer -Force

