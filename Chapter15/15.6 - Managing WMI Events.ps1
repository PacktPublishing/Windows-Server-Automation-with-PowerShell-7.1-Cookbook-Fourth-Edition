# 9.5 Managing WMI EVents

# Run in SRV1

# 1. Registering an intrinsic event
$Query1 = "SELECT * FROM __InstanceCreationEvent WITHIN 2 
          WHERE TargetInstance ISA 'Win32_Process'"
$CEHT = @{
  Query            = $Query1
  SourceIdentifier = 'NewProcessEvent'
}          
Register-CimIndicationEvent @CEHT

# 2. Running Notepad to trigger the event
notepad.exe

# 3. Getting the new process event
$Event = Get-Event -SourceIdentifier 'NewProcessEvent' | 
           Select-Object -Last 1

# 4. Displaying event details
$Event.SourceEventArgs.NewEvent.TargetInstance

# 5. Unregistering the event
Unregister-Event -SourceIdentifier 'NewProcessEvent'

# 6. Registering an event query based on the registry provider
New-Item -Path 'HKLM:\SOFTWARE\Packt' | Out-Null
$Query2 = "SELECT * FROM RegistryValueChangeEvent 
            WHERE Hive='HKEY_LOCAL_MACHINE' 
              AND KeyPath='SOFTWARE\\Packt' AND ValueName='MOLTUAE'"
$Action2 = { 
  Write-Host -Object "Registry Value Change Event Occurred"
  $Global:RegEvent = $Event 
}
Register-CimIndicationEvent -Query $Query2 -Action $Action2 -Source RegChange

# 7. Creating a new registry key and setting a value entry
$Q2HT = [ordered] @{
  Type  = 'DWord'
  Name  = 'MOLTUAE' 
  Path  = 'HKLM:\Software\Packt' 
  Value = 42 
}
Set-ItemProperty @Q2HT
Get-ItemProperty -Path HKLM:\SOFTWARE\Packt

# 8. Unregistering the event
Unregister-Event -SourceIdentifier 'RegChange'

# 9. Examining event details
$RegEvent.SourceEventArgs.NewEvent

# 10. Creating a WQL event query
$Group = 'Enterprise Admins'
$Query1 = @"
  Select * From __InstanceModificationEvent Within 5  
   Where TargetInstance ISA 'ds_group' AND 
         TargetInstance.ds_name = '$Group'
"@

# 11. Creating a temporary WMI event registration
$Event = @{
  Namespace =  'root\directory\LDAP'
  SourceID  = 'DSGroupChange'
  Query     = $Query1
  Action    = {
    $Global:ADEvent = $Event
    Write-Host 'We have a group change'
  }
}
Register-CimIndicationEvent @Event

# 12. Adding a user to the Enterprise Admins group
Add-ADGroupMember -Identity 'Enterprise Admins' -Members Malcolm

# 13. Viewing the newly added user
$ADEvent.SourceEventArgs.NewEvent.TargetInstance | 
  Format-Table -Property DS_sAMAccountName,DS_Member

# 14. Unregistering the event
Unregister-Event -SourceIdentifier 'DSGroupChange'



