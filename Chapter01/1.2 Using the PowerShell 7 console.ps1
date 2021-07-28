# 1.2 Using the PowerShell 7 Console
#
# Run on SRV1 after you install PowerShell
# Run in elevated console

# 1. Run PowerShell 7 From the Command Line

Start/PWSH/Return

# 2. Viewing the PowerShell version
$PSVersionTable

# 3. Viewing the $Host variable
$Host

# 4. Looking at the PowerShell process
Get-Process -Id $PID |
  Format-Custom -Property MainModule -Depth 1

# 5. Looking at resource usage statistics
Get-Process -Id $PID |
  Format-List CPU,*Memory*

# 6. Updating the PowerShell help
$Before = Get-Help -Name about_*
Update-Help -Force | Out-Null
$After = Get-Help -Name about_*
$Delta = $After.Count - $Before.Count
"{0} Conceptual Help Files Added" -f $Delta

# 7. How many commands are available?
Get-Command |
  Group-Object -Property CommandType