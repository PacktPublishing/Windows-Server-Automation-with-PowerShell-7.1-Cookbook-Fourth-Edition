# Recipe 11.6 - Modifying printer security
#
# Run on PSRV - domain joined host in reskit.org domain

# 1. Setting up AD for this recipe
$SB = {
  # 1.1 Creating Sales OU
  $OUHT = @{
    Name = 'Sales'
    Path = 'DC=Reskit,DC=Org'
  }
  New-ADOrganizationalUnit @OUHT
  # 1.2 Creating Sales Group 
  $G1HT = @{
    Name       = 'SalesGroup'
    GroupScope = 'Universal'
    Path       = 'OU=Sales,DC=Reskit,DC=Org'
  }
  New-ADGroup @G1HT
  # 1.3 Creating SalesAdmin Group
   $G2HT = @{
     Name       = 'SalesAdmins'
     GroupScope = 'Universal'
     Path       = 'OU=Sales,DC=Reskit,DC=Org'
   }
   New-ADGroup @G2HT
 } 
 # 1.4 Running Script block on DC1
 Invoke-Command -ComputerName DC1 -ScriptBlock $SB
 
 # 2. Getting the group to allow access
 $GHT1 = @{
     Typename     = 'Security.Principal.NTAccount'
     Argumentlist = 'SalesGroup'
 }
 $SalesGroup = New-Object @GHT1
 $GHT2 = @{
     Typename     = 'Security.Principal.NTAccount'
     Argumentlist = 'SalesAdmins'
 }
 $SalesAdminGroup = New-Object @GHT2
 
 # 3. Getting the group SIDs
 $SalesGroupSid = 
   $SalesGroup.Translate([Security.Principal.Securityidentifier]).Value
 $SalesAdminGroupSid = 
   $SalesAdminGroup.Translate(
     [Security.Principal.Securityidentifier]).Value
 
 # 4. Defining the SDDL for this printer
 $SDDL = 'O:BAG:DUD:PAI(A;OICI;FA;;;DA)' +         
         "(A;OICI;0x3D8F8;;;$SalesGroupSid)"+     
         "(A;;LCSWSDRCWDWO;;;$SalesAdminGroupSid)" 
 
 # 5. Getting the Sales group's printer object
 $SGPrinter = Get-Printer -Name SalesPrinter1 -Full
 
 # 6. Setting the permissions
 $SGPrinter | Set-Printer -Permission $SDDL
 
 # 7. Viewing the permissions from the GUI
 Run this from Settings in Windows