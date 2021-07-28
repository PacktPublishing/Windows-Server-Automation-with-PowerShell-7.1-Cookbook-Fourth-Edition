# 8.5 - Using Script Block Logging

# Run on SRV1, login as admin

# 1. Clearing PowerShell Core operational log
wevtutil.exe cl 'PowerShellCore/Operational'

# 2. Enabling script block logging for the current user
$SBLPath = 'HKCU:\Software\Policies\Microsoft\PowerShellCore' +
           '\ScriptBlockLogging'
if (-not (Test-Path $SBLPath))  {
        $null = New-Item $SBLPath -Force
    }
Set-ItemProperty $SBLPath -Name EnableScriptBlockLogging -Value '1'

# 3. Examining the PowerShell Core event log for 4104 events
Get-Winevent -LogName 'PowerShellCore/Operational' |
  Where-Object Id -eq 4104
  
# 4. Examining logged event details  
Get-Winevent -LogName 'PowerShellCore/Operational' |
  Where-Object Id -eq 4104  | 
    Select-Object -First 1 |
      Format-List -Property ID, Logname, Message

# 5. Creating another script block that Powershell does not log
$SBtolog = {Get-CimInstance -Class Win32_ComputerSystem | Out-Null}   
$Before = Get-WinEvent -LogName 'PowerShellCore/Operational'
Invoke-Command -ScriptBlock $SBtolog
$After = Get-WinEvent -LogName 'PowerShellCore/Operational'

# 6. Comparing the events before and after you invoke the command
"Before:  $($Before.Count) events"
"After :  $($After.Count) events"

# 7. Removing registry policy entry
Remove-Item -Path $SBLPath

