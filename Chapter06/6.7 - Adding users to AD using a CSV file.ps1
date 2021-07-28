# 6.6 - Adding Users to Active Directory using a CSV File

# Run On DC1

# 1. Creating a CSV file
$CSVDATA = @'
Firstname,Initials,Lastname,UserPrincipalName,Alias,Description,Password
J, K, Smith, JKS, James, Data Team, Christmas42
Clair, B, Smith, CBS, Claire, Receptionist, Christmas42
Billy, Bob, JoeBob, BBJB, BillyBob, A Bob, Christmas42
Malcolm, Dudley, Duewrong, Malcolm, Malcolm, Mr Danger, Christmas42
'@
$CSVDATA | Out-File -FilePath C:\Foo\Users.Csv

# 2. Importing and displaying the CSV
$Users = Import-CSV -Path C:\Foo\Users.Csv | 
  Sort-Object  -Property Alias
$Users | Format-Table

# 3. Adding the users using the CSV
$Users | 
  ForEach-Object -Parallel {
    $User = $_ 
    #  Create a hash table of properties to set on created user
    $Prop = @{}
    #  Fill in values
    $Prop.GivenName         = $User.Firstname
    $Prop.Initials          = $User.Initials
    $Prop.Surname           = $User.Lastname
    $Prop.UserPrincipalName = $User.UserPrincipalName + "@Reskit.Org"
    $Prop.Displayname       = $User.FirstName.Trim() + " " +
                              $User.LastName.Trim()
    $Prop.Description       = $User.Description
    $Prop.Name              = $User.Alias
    $PW = ConvertTo-SecureString -AsPlainText $User.Password -Force
    $Prop.AccountPassword   = $PW
    $Prop.ChangePasswordAtLogon = $true
    $Prop.Path                  = 'OU=IT,DC=Reskit,DC=ORG'
    $Prop.Enabled               = $true
    #  Now Create the User
    New-ADUser @Prop
    # Finally, Display User Created
    "Created $($Prop.Name)"
}

# 4. Showing all users in AD (Reskit.Org)
Get-ADUser -Filter * | 
  Format-Table -Property Name, UserPrincipalName






### Remove the users created in the script

$Users = Import-Csv C:\foo\users.csv
foreach ($User in $Users)
{
  Get-ADUser -Identity $user.alias | Remove-AdUser
}




