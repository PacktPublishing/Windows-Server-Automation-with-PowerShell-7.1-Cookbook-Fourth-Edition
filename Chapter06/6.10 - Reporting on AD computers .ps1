# Recipe 6.10 - Reporting on AD Computers

# Run on DC1 after creating the domain and adding computers.

# 1. Creating example computer accounts in the AD
$NCHT1 = @{
    Name        = 'NLIComputer1_1week'
    Description = 'Computer last logged in 1 week ago'
}
New-ADComputer @NCHT1
$NCHT2 = @{
  Name        = 'NLIComputer2_1month'
  Description = 'Computer last logged in 1 week ago'
}
New-ADComputer @NCHT2
$NCHT3 = @{
  Name        = 'NLIComputer3_6month'
  Description = 'Computer last logged in 1 week ago'
}
New-ADComputer @NCHT3

# 2. Creating some constants for later comparison
$OneWeekAgo   = (Get-Date).AddDays(-7)
$OneMonthAgo  = (Get-Date).AddMonths(-1)
$SixMonthsAgo = (Get-Date).AddMonths(-6)

# 3. Defining a function to create sample data
Function Get-RKComputers {
$ADComputers = Get-ADComputer -Filter * -Properties LastLogonDate
$Computers = @()
foreach ($ADComputer in $ADComputers) {
  $Name = $ADComputer.Name
  # Real computers and last logon date
  if ($adComputer.name -NotMatch "^NLI") {
    $LLD = $ADComputer.LastLogonDate       
  }
  Elseif ($ADComputer.Name -eq "NLIComputer1_1week")  {
    $LLD = $OneWeekAgo.AddMinutes(-30)
  }
  Elseif ($ADComputer.Name -eq "NLIComputer2_1month")  {
    $LLD = $OneMonthAgo.AddMinutes(-30)
  }
  Elseif ($ADComputer.Name -eq "NLIComputer3_6month")  {
    $LLD = $SixMonthsAgo.AddMinutes(-30)
  }
  $Computers += [pscustomobject] @{
    Name = $Name
    LastLogonDate = $LLD
  }
}
$Computers
}

# 4. Building the report header
$RKReport = ''           # Start of report
$RKReport += "*** Reskit.Org AD Daily AD Computer Report`n"
$RKReport += "*** Generated [$(Get-Date)]`n"
$RKReport += "***********************************`n`n"

# 5. Getting Computers in RK AD using Get-RKComputers
$Computers = Get-RKComputers

# 6. Getting computers that have never logged on
$RKReport += "Computers that have never logged on`n"
$RkReport += "Name                    LastLogonDate`n"
$RkReport += "----                    -------------`n"
$RKReport += Foreach($Computer in $Computers) {
  If ($null -eq $Computer.LastLogonDate) {
   "{0,-22}  {1}  `n" -f $Computer.Name, "Never"
  }
}

# 7. Reporting on computers who have not logged on in over 6 months
$RKReport += "`nComputers that havent logged in over 6 months`n"
$RkReport += "Name                    LastLogonDate`n"
$RkReport += "----                    -------------`n"
$RKReport +=
foreach($Computer in $Computers) {
  If (($Computer.LastLogonDate -lt $SixMonthsAgo) -and 
      ($null -ne $Computer.LastLogonDate)) {
("`n{0,-23}  {1}  `n" -f $Computer.Name, $Computer.LastLogonDate)
  }
}

# 8. Reporting on computer accounts that have not logged in 1-6 months ago
$RKReport += "`n`nComputers that havent logged in 1-6 months`n"
$RkReport += "Name                    LastLogonDate`n"
$RkReport += "----                    -------------"
$RKReport +=
foreach($Computer in $Computers) {
  If (($Computer.LastLogonDate -ge $SixMonthsAgo) -and
     ($Computer.LastLogonDate -lt $OneMonthAgo) -and     
       ($null -ne $Computer.LastLogonDate)) {
   "`n{0,-22}  {1}  " -f $Computer.Name, $Computer.LastLogonDate
  }
}

# 9. Reporting on computer accounts that have not logged in
#    the past 1 week to one month ago
$RKReport += "`n`nComputers that have between one week "
$RKReport += "and one month ago`n"
$RkReport += "Name                    LastLogonDate`n"
$RkReport += "----                    -------------"
$RKReport +=
foreach($Computer in $Computers) {
  If (($Computer.LastLogonDate -ge $OneMonthAgo) -and
     ($Computer.LastLogonDate -lt $OneWeekAgo) -and     
       ($null -ne $Computer.LastLogonDate)) {
   "`n{0,-22}  {1}  " -f $Computer.Name, $Computer.LastLogonDate
  }
}


#10. Displaying the report
$RKReport