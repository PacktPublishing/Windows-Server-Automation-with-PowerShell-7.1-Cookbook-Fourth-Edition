# 3.6 - Leveraging Compatibility.ps1

# run on SRV1 after installing PowerShell 7 and VS Code.
# Ensure you start a fresh session (or create a new terminal in VS Code)
# run in an elevated console as well.;

# 1. Creating a session using the reserved name
$S1 = New-PSSession -Name WinPSCompatSession -ComputerName SRV1

# 2. Getting loaded modules in the remote session
Invoke-Command -Session $S1 -ScriptBlock {Get-Module}

# 3. Loading the ServerManger module in the remote session
Import-Module -Name ServerManager -WarningAction SilentlyContinue |
  Out-Null

# 4. Getting loaded modules in remote session
Invoke-Command -Session $S1 -ScriptBlock {Get-Module}

# 5. Using Get-WindowsFeature
Get-WindowsFeature -Name PowerShell

# 6. Closing remoting sessions and removing module from current PS7 session
Get-PSSession| Remove-PSSession
Get-Module -Name ServerManager | Remove-Module

# 7. Creating a default compatibility remoting session
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 8. Getting the new remoting session
$S2 = Get-PSSession -Name 'WinPSCompatSession'
$S2

# 9. Examining modules in WInPSCompatSessionb
Invoke-Command -Session $S2 -ScriptBlock {Get-Module}
