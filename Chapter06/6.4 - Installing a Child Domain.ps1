# 6.4 - Installing a Child Domain

# Run on UKDC1 - a domain joined server initially in the Reskit.Org domain
# also, have DC1.Reskit.Org online

# 1. Importing the ServerManager module
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 2. Checking DC1 can be resolved
Resolve-DnsName -Name DC1.Reskit.Org -Type A

# 3. Checking network connection to DC1
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 445
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 389

# 4. Adding the AD DS features on UKDC1
$Features = 'AD-Domain-Services'
Install-WindowsFeature -Name $Features -IncludeManagementTools

# 5. Creating a credential and installation hash table
Import-Module -Name ADDSDeployment -WarningAction SilentlyContinue
$URK    = "Administrator@Reskit.Org" 
$PW     = 'Pa$$w0rd'
$PSS    = ConvertTo-SecureString -String $PW -AsPlainText -Force
$CredRK = [PSCredential]::New($URK,$PSS)
$INSTALLHT    = @{
  NewDomainName                 = 'UK'
  ParentDomainName              = 'Reskit.Org'
  DomainType                    = 'ChildDomain'
  SafeModeAdministratorPassword = $PSS
  ReplicationSourceDC           = 'DC1.Reskit.Org'
  Credential                    = $CredRK
  SiteName                      = 'Default-First-Site-Name'
  InstallDNS                    = $false
  Force                         = $true
}

# 6. Installing child domain
Install-ADDSDomain @INSTALLHT

### after roboot - login as UK\Administrator  

# 7. Looking at the AD forest
Get-ADForest -Server UKDC1.UK.Reskit.Org

# 8. Looking at the UK domain
Get-ADDomain -Server UKDC1.UK.Reskit.Org
