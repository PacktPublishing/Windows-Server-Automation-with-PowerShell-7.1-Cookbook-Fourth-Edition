# 6.7 - Managing AD Computers

# Run first on DC1 - with prior recipies competed
# DC1, UKDC1, and SRV1 online

# 1. Getting computers in the Reskit Domain
Get-ADComputer -Filter * |
  Format-Table -Property Name, DistinguishedName

# 2. Getting computers in the UK Domain
Get-ADComputer -Filter * -Server UKDC1.UK.Reskit.Org |
  Format-Table -Property Name, DistinguishedName

# 3. Creating a new computer in the Reskit.Org domain
$NCHT = @{
    Name                   = 'Wolf' 
    DNSHostName            = 'Wolf.Reskit.Org'
    Description            = 'One for Jerry'
    Path                   = 'OU=IT,DC=Reskit,DC=Org'
}
New-ADComputer @NCHT

# 4. Creating Credential Object for SRV1
$ASRV1    = 'SRV1\Administrator'
$PSRV1    = 'Pa$$w0rd'
$PSSRV1   = ConvertTo-SecureString -String $PSRV1 -AsPlainText -Force
$CredSRV1 = [pscredential]::New($ASRV1, $PSSRV1)

# 5. Creating a script block to Join SRV1
$SB = {
  $ARK    = 'Reskit\Administrator'
  $PRK    = 'Pa$$w0rd'
  $PSRK   = ConvertTo-SecureString -String $PRK -AsPlainText -Force
  $CredRK = [pscredential]::New($ARK, $PSRK)
  $DJHT = @{
    DomainName  = 'Reskit.Org'
    OUPath      = 'OU=IT,DC=Reskit,DC=Org'
    Credential  = $CredRK
    Restart     = $false
 }
    Add-Computer @DJHT
}  

# 6. Joining the computer to the domain
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
Invoke-Command -ComputerName SRV1 -Credential $CredSRV1 -ScriptBlock $SB

# 7. Restarting SRV1
Restart-Computer -ComputerName SRV1 -Credential $CredSRV1 -Force

# 8. Viewing the resulting computer accounts for Reskit.Org
Get-ADComputer -Filter * -Properties DNSHostName,LastLogonDate | 
  Format-Table -Property Name, DNSHostName, Enabled