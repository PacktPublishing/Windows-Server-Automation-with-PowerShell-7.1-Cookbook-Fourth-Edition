# Recipe 6.8 - Creating group policy objects

# Run on DC1, after creaating IT Organizational Unit

# 1. Creating a Group Policy object
$Pol = New-GPO -Name ITPolicy -Comment "IT GPO" -Domain Reskit.Org

# 2. Ensuring just computer settings are enabled
$Pol.GpoStatus = 'UserSettingsDisabled'

# 3. Configuring the policy with two registry based settings
$EPHT1= @{
  Name   = 'ITPolicy'
  Key    = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell'
  ValueName = 'ExecutionPolicy'
  Value  = 'Unrestricted' 
  Type   = 'String'
}
Set-GPRegistryValue @EPHT1 | Out-Null
$EPHT2= @{
  Name   = 'ITPolicy'
  Key    = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell'
  ValueName = 'EnableScripts'
  Type   = 'DWord'
  Value  = 1 
}
Set-GPRegistryValue @EPHT2 | Out-Null

# 4. Creating a screen saver GPO 
$Pol2 = New-GPO -Name 'Screen Saver Time Out' 
$Pol2.GpoStatus   = 'ComputerSettingsDisabled'
$Pol2.Description = '15 minute timeout'

# 5. Setting a Group Policy enforced registry value
$EPHT3= @{
  Name   = 'Screen Saver Time Out'
  Key    = 'HKCU\Software\Policies\Microsoft\Windows\'+
              'Control Panel\Desktop'
  ValueName = 'ScreenSaveTimeOut'
  Value  = 900 
  Type   = 'DWord'
} 
Set-GPRegistryValue @EPHT3 | Out-Null

# 6. Linking both GPOs to the IT OU
$GPLHT1 = @{
  Name     = 'ITPolicy'
  Target   = 'OU=IT,DC=Reskit,DC=org'
}
New-GPLink @GPLHT1 | Out-Null
$GPLHT2 = @{
  Name     = 'Screen Saver Time Out'
  Target   = 'OU=IT,DC=Reskit,DC=org'
}
New-GPLink @GPLHT2 | Out-Null

# 7. Displaying the GPOs in the domain
Get-GPO -All -Domain Reskit.Org |
  Sort-Object -Property DisplayName |
    Format-Table -Property Displayname, Description, GpoStatus

# 8. Creating and view a GPO Report
$RPath = 'C:\Foo\GPOReport1.HTML'
Get-GPOReport -All -ReportType Html -Path $RPath
Invoke-Item -Path $RPath

# 9. Getting report in XML format
$RPath2 = 'C:\Foo\GPOReport2.XML'
Get-GPOReport -All -ReportType XML -Path $RPath2
$XML = [xml] (Get-Content -Path $RPath2)

# 10. Creating simple GPO report
$RPath2 = 'C:\Foo\GPOReport2.XML'
$FMTS = "{0,-33}  {1,-30} {2,-10} {3}"
$FMTS -f 'Name','Linked To', 'Enabled', 'No Override'
$FMTS -f '----','---------', '-------', '-----------'
$XML.report.GPO | 
  Sort-Object -Property Name |
    ForEach-Object {
     $Gname = $_.Name
     $SOM = $_.linksto.SomPath
     $ENA = $_.linksto.enabled
     $NOO = $_.linksto.nooverride
     $FMTS -f $Gname, $SOM, $ENA, $NOO
   }




# to undo for testing
# these steps remove the GPOs created above

Remove-GPLink -Name 'Screen Saver Time Out'  -Target 'OU=IT,DC=Reskit,DC=Org'
Remove-GPLink -Name 'ITPolicy'  -Target 'OU=IT,DC=Reskit,DC=Org'
Get-GPO 'ITPolicy' | Remove-GPO
Get-GPO 'Screen Saver Time Out' | remove-GPO
Get-GPO -Domain 'Reskit.Org' -All |
  Format-Table -Property DisplayName, GPOStatus, Description