# 8.3 - Discovering Logon Events

# Run on DC1


# 1. Getting Security log events
$SecLog = Get-WinEvent -ListLog Security
"Security Event log entries:    [{0,10:N0}]" -f $Seclog.RecordCount

# 2. Getting all Windows Security log event details
$SecEvents = Get-WinEvent -LogName Security 
"Found $($SecEvents.count) security events on DC1"

# 3: Examining Security event log event members
$SecEvents | 
  Get-Member

# 4. Summarizing security events by event ID
$SecEvents | 
  Sort-Object -Property Id | 
    Group-Object -Property ID | 
      Sort-Object -Property Name |
        Format-Table -Property Name, Count

# 5. Getting all successful logon events on DC1
$Logons = $SecEvents | Where-Object ID -eq 4624   # logon event
"Found $($Logons.Count) logon events on DC1"

# 6. Getting all failed logon events on DC1
$FLogons = $SecEvents | Where-Object ID -eq 4625   # failed logon event
"Found $($FLogons.Count) failed logon events on DC1"

# 7. Creating a summary array of successful logon events
$LogonEvents = @()
Foreach ($Logon in $Logons) {
  $XMLMSG = [xml] $Logon.ToXml()
  $Text = '#text'
  $HostName   = $XMLMSG.Event.EventData.data.$Text[1]
  $HostDomain = $XMLMSG.Event.EventData.data.$Text[2]
  $Account    = $XMLMSG.Event.EventData.data.$Text[5]
  $AcctDomain = $XMLMSG.Event.EventData.data.$Text[6]
  $LogonType  = $XMLMSG.Event.EventData.data.$Text[8]
  $LogonEvent = New-Object -Type PSCustomObject -Property @{
     Account   = "$AcctDomain\$Account"
     Host      = "$HostDomain\$Hostname"
     LogonType = $LogonType
     Time      = $Logon.TimeCreated
  }
  $LogonEvents += $logonEvent
}

# 8. Summarizing successful logon events on DC1
$LogonEvents | 
  Group-Object -Property LogonType |
    Sort-Object -Property Name |
      Select-Object -Property Name,Count

# 9. Creating a summary array of failed logon events on DC1
$FLogonEvents = @()
Foreach ($FLogon in $FLogons) {
  $XMLMSG = [xml] $FLogon.ToXml()
  $Text = '#text'
  $HostName   = $XMLMSG.Event.EventData.data.$Text[1]
  $HostDomain = $XMLMSG.Event.EventData.data.$Text[2]
  $Account    = $XMLMSG.Event.EventData.data.$Text[5]
  $AcctDomain = $XMLMSG.Event.EventData.data.$Text[6]
  $LogonType  = $XMLMSG.Event.EventData.data.$Text[8]
  $LogonEvent = New-Object -Type PSCustomObject -Property @{
     Account   = "$AcctDomain\$Account"
     Host      = "$HostDomain\$Hostname"
     LogonType = $LogonType
     Time      = $FLogon.TimeCreated
  }
  $FLogonEvents += $LogonEvent
}      

# 10. Summarizing failed logon events on DC1
$FLogonEvents | 
  Group-Object -Property Account |
    Sort-Object -Property Name |
      Format-Table Name, Count
