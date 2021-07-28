# 10.9 - Implementing Filestore Screening
# 
# Run on SRV1 with FSRM loaded

# 1. Examining the existing file groups
Get-FsrmFileGroup |
  Format-Table -Property Name, IncludePattern

# 2. Examining the existing file screening templates
Get-FsrmFileScreenTemplate |
  Format-Table -Property Name, IncludeGroup, Active

# 3. Creating a new folder
$Path = 'C:\FileScreen'
If (-Not (Test-Path $Path)) {
  New-Item -Path $Path -ItemType Directory  |
    Out-Null
}

# 4. Creating a new file screen
$FSHT =  @{
  Path         = $Path
  Description  = 'Block Executable Files'
  IncludeGroup = 'Executable Files'
}
New-FsrmFileScreen @FSHT

# 5. Testing file screen by copying notepad.exe
$FSTHT = @{
  Path        = "$Env:windir\notepad.exe"
  Destination = 'C:\FileScreen\notepad.exe'
}
Copy-Item  @FSTHT

# 6. Setting up an active email notification
$Body = 
"[Source Io Owner] attempted to save an executable program to 
[File Screen Path].

This is not allowed!
"
$FSRMA = @{
  Type             = 'Email'
  MailTo           = 'DoctorDNS@Gmail.Com' 
  Subject          = 'Warning: attempted to save an executable file'
  Body             = $Body
  RunLimitInterval = 60
}
$Notification = New-FsrmAction @FSRMA
$FSFS = @{
  Path         = $Path
  Notification = $Notification
  IncludeGroup = 'Executable Files'
  Description  = 'Block any executable file'
  Active       = $true
}
Set-FsrmFileScreen @FSFS 

# 7. Geting FSRM Notification Limits
Get-FsrmSetting | 
  Format-List -Property "*NotificationLimit"

# 8. Changing FSRM notification limits  
$FSRMSHT = @{
  CommandNotificationLimit = 1
  EmailNotificationLimit   = 1
  EventNotificationLimit   = 1
  ReportNotificationLimit  = 1
}
Set-FsrmSetting @FSRMSHT


# 9. Re-testing the file screen to check the action
Copy-Item @FSTHT

# 10. Viewing file scewwning email
no output, but...
# 
View from Outlook




# for testing
get-adgroupmember -identity 'Enterprise admins'
Add-ADGroupMember -Identity 'Enterprise Admins' -members jerryg
get-adgroupmember -identity 'Enterprise admins' | ft name
$sb = {
  $FSTHT = @{
    Path        = "$Env:windir\notepad.exe"
    Destination = '\\srv1\screen\notepad.txt'
  }
  Copy-Item  @FSTHT
}
Invoke-command -ComputerName srv1 -ScriptBlock $sb -Credential $cred



new-smbshare -name screen -path C:\FileScreen


