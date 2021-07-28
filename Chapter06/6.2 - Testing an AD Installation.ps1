# 6.2 - Testing AD Installation

# Run this recipe on DC1 after promotion
# Login as Enterprise Admin.

# 1. Examining Root Directory Service Entry (DSE)
Get-ADRootDSE -Server DC1.Reskit.Org

# 2. Viewing AD forest details
Get-ADForest

# 3. Viewing AD Domain details
Get-ADDomain

# 4. Checking Netlogon, ADWS, and DNS services
Get-Service NetLogon, ADWS, DNS 

# 5. Getting initial AD uUsers
Get-ADUser -Filter * |
  Sort-Object -Property Name |
    Format-Table -Property Name, DistinguishedName

# 6. Getting initial AD groups
Get-ADGroup -Filter *  |
  Sort-Object -Property Groupscope,Name |
    Format-Table -Property Name, GroupScope

# 7. Examining Enterprise Admins group membership
Get-ADGroupMember -Identity 'Enterprise Admins'  

# 8. Checking DNS zones on DC1
Get-DnsServerZone -ComputerName DC1  

# 9. Testing domain name DNS resolution 
Resolve-DnsName -Name Reskit.Org 