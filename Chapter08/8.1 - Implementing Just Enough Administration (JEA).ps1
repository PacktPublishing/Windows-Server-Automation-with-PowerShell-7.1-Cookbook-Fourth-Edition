8.1 Implementing Just Enough Administration (JEA)

# Run on DC1
# Relies on AD IT OU, the user JerryG which you created these in Chapter 6.

# 1. Creating a transcripts folder 
New-Item -Path C:\JEATranscripts -ItemType Directory | 
  Out-Null

# 2. Creating a role capabilities folder
$JEACF = "C:\JEACapabilities"
New-Item -Path $JEACF -ItemType Directory | 
  Out-Null

# 3. Creating a JEA session configuration folder
$SCF = 'C:\JEASessionConfiguration'
New-Item -Path $SCF -ItemType Directory | 
  Out-Null

# 4. Creating DNSAdminsJEA as a global security group
$DNSGHT = @{
  Name          = 'DNSAdminsJEA'
  Description   = 'DNS Admins for JEA'
  GroupCategory = 'Security'
  GroupScope    = 'Global'
}
New-ADGroup @DNSGHT
Get-ADGroup -Identity 'DNSAdminsJEA' |
  Move-ADObject -TargetPath 'OU=IT, DC=Reskit, DC=Org'

# 5. Adding JerryG to the DNS Admins group
$ADGHT = @{
  Identity  = 'DNSAdminsJEA'
  Members   = 'JerryG'
}
Add-ADGroupMember @ADGHT  

# 6. Creating a role capabilities file
$RCF = Join-Path -Path $JEACF -ChildPath "DnsAdmins.psrc"
$RCHT = @{
  Path            = $RCF
  Author          = 'Reskit Administration'
  CompanyName     = 'Reskit.Org' 
  Description     = 'DnsAdminsJEA role capabilities'
  AliasDefinition = @{Name='gh';Value='Get-Help'}
  ModulesToImport = 'Microsoft.PowerShell.Core','DnsServer'
  VisibleCmdlets  = (@{ Name        = 'Restart-Computer'; 
                        Parameters  = @{Name = 'ComputerName'}
                        ValidateSet = 'DC1, DC2'},
                       'DNSSERVER\*',
                     @{ Name        = 'Stop-Service'; 
                        Parameters  = @{Name = 'DNS'}},                  
                     @{ Name        = 'Start-Service'; 
                        Parameters  = @{Name = 'DNS'}}
                     )
  VisibleExternalCommands = ('C:\Windows\System32\whoami.exe',
                             'C:\Windows\System32\ipconfig.exe')
  VisibleFunctions = 'Get-HW'
  FunctionDefinitions = @{
    Name = 'Get-HW'
    Scriptblock = {'Hello JEA World'}}
}
New-PSRoleCapabilityFile @RCHT 

# 7. Creating a JEA session configuration file
$P   = Join-Path -Path $SCF -ChildPath 'DnsAdmins.pssc'
$RDHT = @{
  'DnsAdminsJEA' = 
      @{'RoleCapabilityFiles' = 
        'C:\JEACapabilities\DnsAdmins.psrc'}
}
$PSCHT= @{
  Author              = 'DoctorDNS@Gmail.Com'
  Description         = 'Session Definition for DnsAdminsJEA'
  SessionType         = 'RestrictedRemoteServer'   # ie JEA!
  Path                = $P       # Role Capabilties file
  RunAsVirtualAccount = $true
  TranscriptDirectory = 'C:\JeaTranscripts'
  RoleDefinitions     = $RDHT     # tk role mapping
}
New-PSSessionConfigurationFile @PSCHT

# 8. Testing the session configuration file
Test-PSSessionConfigurationFile -Path $P 

# 9. Enabling remoting on DC1
Enable-PSRemoting -Force | 
  Out-Null

# 10. Registering the JEA session configuration remoting endpoint
$SCHT = @{
  Path  = $P
  Name  = 'DnsAdminsJEA' 
  Force =  $true 
}
Register-PSSessionConfiguration @SCHT

# 11. Viewing remoting endpoints
Get-PSSessionConfiguration  |
  Format-Table -Property Name, PSVersion, Run*Account

# 12. Verifying what the user can do
$SCHT = @{
  ConfigurationName = 'DnsAdminsJEA'
  Username          = 'Reskit\JerryG' 
}
Get-PSSessionCapability  @SCHT |
  Sort-Object -Property Module

# 13. Creating credentials for user JerryG
$U    = 'JerryG@Reskit.Org'
$P    = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force 
$Cred = [PSCredential]::New($U,$P)

# 14. Defining three script blocks and an invocation splatting hash table
$SB1   = {Get-Command}
$SB2   = {Get-HW}
$SB3   = {Get-Command -Name  '*-DNSSERVER*'}
$ICMHT = @{
  ComputerName      = 'DC1.Reskit.Org'
  Credential        = $Cred 
  ConfigurationName = 'DnsAdminsJEA' 
} 

# 15. Getting commands available within the JEA session
Invoke-Command -ScriptBlock $SB1 @ICMHT |
  Sort-Object -Property Module |
    Select-Object -First 15

# 16. Invoking a JEA-defined function in a JEA session as JerryG
Invoke-Command -ScriptBlock $SB2 @ICMHT

# 17. Getting DNSServer commands available to JerryG
$C = Invoke-Command -ScriptBlock $SB3 @ICMHT 
"$($C.Count) DNS commands available"

# 18. Examining the contents of the transcripts folder
Get-ChildItem -Path $PSCHT.TranscriptDirectory

# 19. Examining a transcript
Get-ChildItem -Path $PSCHT.TranscriptDirectory | 
  Select-Object -First 1  |
    Get-Content 



# testing
Get-PSSessionConfiguration D* | Unregister-PSSessionConfiguration

Enter-PSSession @ICMHT

$sb4 = {"DsRoleSvc" | start-Service -Verbose}
$sb4 = {Start-Service -Name DNS -Verbose}
Invoke-Command -ScriptBlock $SB4 @ICMHT

