# Recipe 6.11 - Reporting on AD Users

# Run on DC1


# 1. 1.	Defining a function Get-ReskitUser to return objects related to users in Reskit.Org domain 
Function Get-ReskitUser {
# Get PDC Emulator DC
$PrimaryDC = Get-ADDomainController -Discover -Service PrimaryDC
# Get Users
$ADUsers = Get-ADUser -Filter * -Properties * -Server $PrimaryDC
# Iterate through them and create $Userinfo hash table:
Foreach ($ADUser in $ADUsers) {
    # Create a userinfo HT
    $UserInfo = [Ordered] @{}
    $UserInfo.SamAccountname = $ADUser.SamAccountName
    $Userinfo.DisplayName    = $ADUser.DisplayName
    $UserInfo.Office         = $ADUser.Office
    $Userinfo.Enabled        = $ADUser.Enabled
    $userinfo.LastLogonDate  = $ADUser.LastLogonDate
    $UserInfo.ProfilePath    = $ADUser.ProfilePath
    $Userinfo.ScriptPath     = $ADUser.ScriptPath
    $UserInfo.BadPWDCount    = $ADUser.badPwdCount
    New-Object -TypeName PSObject -Property $UserInfo
    }
} # end of function

# 2. Getting the users
$RKUsers = Get-ReskitUser

# 3. Building the report header
$RKReport = ''  # first line of the report
$RkReport += "*** Reskit.Org AD Report`n"
$RKReport += "*** Generated [$(Get-Date)]`n"
$RKReport += "*******************************`n`n"

# 4. Reporting on disabled users
$RkReport += "*** Disabled Users`n"
$RKReport += $RKUsers |
    Where-Object {$_.Enabled -NE $true} |
        Format-Table -Property SamAccountName, Displayname |
            Out-String

# 5. Reporting on users who have not recently logged on
$OneWeekAgo = (Get-Date).AddDays(-7)
$RKReport += "`n*** Users Not logged in since $OneWeekAgo`n"
$RkReport += $RKUsers |
    Where-Object {$_.Enabled -and $_.LastLogonDate -le $OneWeekAgo} |
        Sort-Object -Property LastlogonDate |
            Format-Table -Property SamAccountName,lastlogondate |
                Out-String

# 6. Discovering users with a high number of invalid password attempts
$RKReport += "`n*** High Number of Bad Password Attempts`n"
$RKReport += $RKUsers | Where-Object BadPwdCount -ge 5 |
  Format-Table -Property SamAccountName, BadPwdCount |
    Out-String

# 7. Adding Another report header line for this part of the 
#    report and create an empty array of priviledged users
$RKReport += "`n*** Privileged  User Report`n"
$PUsers = @()

# 8. Querying the Enterprise Admins/Domain Admins/Scheme Admins
#    groups for members and adding them to the $Pusers array
# Get Enterprise Admins group members
$Members = Get-ADGroupMember -Identity 'Enterprise Admins' -Recursive |
    Sort-Object -Property Name
$PUsers += foreach ($Member in $Members) {
    Get-ADUser -Identity $Member.SID -Properties * |
        Select-Object -Property Name,
               @{Name='Group';expression={'Enterprise Admins'}},
               whenCreated,LastLogonDate
}
# Get Domain Admins group members
$Members = 
  Get-ADGroupMember -Identity 'Domain Admins' -Recursive |
    Sort-Object -Property Name
$PUsers += Foreach ($Member in $Members)
    {Get-ADUser -Identity $member.SID -Properties * |
        Select-Object -Property Name,
                @{Name='Group';expression={'Domain Admins'}},
                WhenCreated, Lastlogondate,SamAccountName
}
# Get Schema Admins members
$Members = 
  Get-ADGroupMember -Identity 'Schema Admins' -Recursive |
    Sort-Object Name
$PUsers += Foreach ($Member in $Members) {
    Get-ADUser -Identity $member.SID -Properties * |
        Select-Object -Property Name,
            @{Name='Group';expression={'Schema Admins'}}, 
            WhenCreated, LastLogonDate,SamAccountName
}

# 9 Adding the special users to the report
$RKReport += $PUsers | Out-String

# 10. Displaying the final report
$RKReport