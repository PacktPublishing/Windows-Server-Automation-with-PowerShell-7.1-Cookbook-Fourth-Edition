# 8.6 - Configuring AD Password Policy

#  Run on DC1

# 1. Discovering the current domain password policy
Get-ADDefaultDomainPasswordPolicy  

# 2. Discovering if there is a fine-grained password policy for JerryG
Get-ADFineGrainedPasswordPolicy -Identity 'JerryG'

# 3. Updating the default password policy
$DPWPHT = [Ordered] @{
    LockoutDuration             = '00:45:00' 
    LockoutObservationWindow    = '00:30:00' 
    ComplexityEnabled           = $true
    ReversibleEncryptionEnabled = $false 
    MinPasswordLength           = 6
}
Get-ADDefaultDomainPasswordPolicy -Current LoggedOnUser |
  Set-ADDefaultDomainPasswordPolicy @DPWPHT

# 4. Checking updated default password policy
Get-ADDefaultDomainPasswordPolicy

# 5. Creating a fine-grained password policy
$PD = 'DNS Admins Group Fine-grained Password Policy'
$FGPHT = @{
  Name                     = 'DNSPWP'
  Precedence               = 500 
  ComplexityEnabled        = $true 
  Description              = $PD
  DisplayName              = 'DNS Admins Password Policy'
  LockoutDuration          = '0.12:00:00'
  LockoutObservationWindow = '0.00:42:00'
  LockoutThreshold         = 3
}
New-ADFineGrainedPasswordPolicy @FGPHT

# 6. Assigning the policy to DNSAdmins
$DNSADmins = Get-ADGroup -Identity DNSAdmins
$ADDHT = @{
  Identity  = 'DNSPWP' 
  Subjects  = $DNSADmins
}
Add-ADFineGrainedPasswordPolicySubject  @ADDHT

# 7. Assigning the policy to JerryG
$Jerry = Get-ADUser -Identity JerryG
Add-ADFineGrainedPasswordPolicySubject -Identity DNSPWP -Subjects $Jerry

# 8. Checking on policy application for the group
Get-ADGroup 'DNSAdmins' -Properties * | 
  Select-Object -Property msDS-PSOApplied

# 9. Checking on policy application for the user
Get-ADUser JerryG -Properties * | 
  Select-Object -Property msDS-PSOApplied

# 10. Getting DNS Admins policy
Get-ADFineGrainedPasswordPolicy -Identity DNSPWP

# 11. Checking on JerryG's resultant password policy
Get-ADUserResultantPasswordPolicy -Identity JerryG