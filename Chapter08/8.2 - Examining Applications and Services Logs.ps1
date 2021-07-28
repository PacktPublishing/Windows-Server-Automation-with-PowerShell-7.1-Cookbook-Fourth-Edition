# 8.2 - Examining Event Logs

# Run on SRV1, with DC1 online

# 1. Registering PowerShell event log provider
& $PSHOME\RegisterManifest.ps1

# 2. Discovering classic event logs on SRV1
Get-EventLog -LogName *

# 3. Discovering and measuring all event logs on this host
$Logs = Get-WinEvent -ListLog *
"There are $($Logs.Count) total event logs on SRV1"

# 4. Discovering and measuring all event logs on DC1
$SB1     = {Get-WinEvent -ListLog *}
$LogsDC1 = Invoke-Command -ComputerName DC1 -ScriptBlock $SB1
"There are $($LogsDC1.Count) total event logs on DC1"

# 5. Discovering log member details
$Logs | Get-Member

# 6. Measuring enabled logs on SRV1
$Logs | 
  Where-Object IsEnabled |
    Measure-Object |
      Select-Object -Property Count

# 7. Measuring enabled logs on DC1
$LogsDC1 | 
  Where-Object IsEnabled |
    Measure-Object |
      Select-Object -Property Count

# 8. Measuring enabled logs that have records on SRV1
$Logs | 
  Where-Object IsEnabled |
    Where-Object Recordcount -gt 0 |
      Measure-Object |
        Select-Object -Property Count

# 9. Discovering PowerShell-related logs      
$Logs | 
  Where-Object LogName -match 'powershell'

# 10. Examining PowerShellCore event log
Get-Winevent -LogName 'PowerShellCore/Operational' |
  Select-Object -First 10 
