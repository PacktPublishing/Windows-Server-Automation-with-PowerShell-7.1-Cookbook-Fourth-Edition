# 6.5 - Creating and managing AD users and groups

# Run on DC1 after it is a DC, and after DC2, UKDC1 created as DCs
# Assumes UKDC1 was originally a domain joined computer in the Reskit.Org domain.

# 1.Creating a hash table for general user attributes
$PW  = 'Pa$$w0rd'
$PSS = ConvertTo-SecureString -String $PW -AsPlainText -Force
$NewUserHT = @{}
$NewUserHT.AccountPassword       = $PSS
$NewUserHT.Enabled               = $true
$NewUserHT.PasswordNeverExpires  = $true
$NewUserHT.ChangePasswordAtLogon = $false

# 2. Creating two new users
# First user
$NewUserHT.SamAccountName    = 'ThomasL'
$NewUserHT.UserPrincipalName = 'thomasL@reskit.org'
$NewUserHT.Name              = 'ThomasL'
$NewUserHT.DisplayName       = 'Thomas Lee (IT)'
New-ADUser @NewUserHT
# Second user
$NewUserHT.SamAccountName    = 'RLT'
$NewUserHT.UserPrincipalName = 'rlt@reskit.org'
$NewUserHT.Name              = 'Rebecca Tanner'
$NewUserHT.DisplayName       = 'Rebecca Tanner (IT)'
New-ADUser @NewUserHT

# 3. Creating an OU for IT
$OUHT = @{
    Name        = 'IT'
    DisplayName = 'Reskit IT Team'
    Path        = 'DC=Reskit,DC=Org'
}
New-ADOrganizationalUnit @OUHT

# 4. Moving users into the OU
$MHT1 = @{
    Identity   = 'CN=ThomasL,CN=Users,DC=Reskit,DC=ORG'
    TargetPath = 'OU=IT,DC=Reskit,DC=Org'
}
Move-ADObject @MHT1
$MHT2 = @{
    Identity = 'CN=Rebecca Tanner,CN=Users,DC=Reskit,DC=ORG'
    TargetPath = 'OU=IT,DC=Reskit,DC=Org'
}
Move-ADObject @MHT2

# 5. Creating a third user directly in the IT OU
$NewUserHT.SamAccountName    = 'JerryG'
$NewUserHT.UserPrincipalName = 'jerryg@reskit.org'
$NewUserHT.Description       = 'Virtualization Team'
$NewUserHT.Name              = 'Jerry Garcia'
$NewUserHT.DisplayName       = 'Jerry Garcia (IT)'
$NewUserHT.Path              = 'OU=IT,DC=Reskit,DC=Org'
New-ADUser @NewUserHT

# 6. Adding two users who get removed later
# First user to be removed
$NewUserHT.SamAccountName    = 'TBR1'
$NewUserHT.UserPrincipalName = 'tbr@reskit.org'
$NewUserHT.Name              = 'TBR1'
$NewUserHT.DisplayName       = 'User to be removed'
$NewUserHT.Path              = 'OU=IT,DC=Reskit,DC=Org'
New-ADUser @NewUserHT
# Second user to be removed
$NewUserHT.SamAccountName     = 'TBR2'
$NewUserHT.UserPrincipalName  = 'tbr2@reskit.org'
$NewUserHT.Name               = 'TBR2'
New-ADUser @NewUserHT

# 7. Viewing existing AD users
Get-ADUser -Filter *  -Property *| 
  Format-Table -Property Name, Displayname, SamAccountName

# 8. Removing via a  Get | Remove pattern
Get-ADUser -Identity 'CN=TBR1,OU=IT,DC=Reskit,DC=Org' |
    Remove-ADUser -Confirm:$false

# 9. Removing a user directly
$RUHT = @{
  Identity = 'CN=TBR2,OU=IT,DC=Reskit,DC=Org'
  Confirm  = $false}
Remove-ADUser @RUHT

# 10. Updating a user object
$TLHT =@{
  Identity     = 'ThomasL'
  OfficePhone  = '4416835420'
  Office       = 'Cookham HQ'
  EmailAddress = 'ThomasL@Reskit.Org'
  GivenName    = 'Thomas'
  Surname      = 'Lee' 
  HomePage     = 'Https://tfl09.blogspot.com'
}
Set-ADUser @TLHT

# 11. Viewing updated user
Get-ADUser -Identity ThomasL -Properties * |
  Format-Table -Property DisplayName,Name,Office,
                         OfficePhone,EmailAddress 

# 12. Creating a new domain local group
$NGHT = @{
 Name        = 'IT Team'
 Path        = 'OU=IT,DC=Reskit,DC=org'
 Description = 'All members of the IT Team'
 GroupScope  = 'DomainLocal'
}
New-ADGroup @NGHT

# 13. Adding all the users in the IT OU into the IT Team group
$SB = 'OU=IT,DC=Reskit,DC=Org'
$ItUsers = Get-ADUser -Filter * -SearchBase $SB
Add-ADGroupMember -Identity 'IT Team'  -Members $ItUsers

# 14. Display members of the IT Team group
Get-ADGroupMember -Identity 'IT Team' |
  Format-Table SamAccountName, DistinguishedName
