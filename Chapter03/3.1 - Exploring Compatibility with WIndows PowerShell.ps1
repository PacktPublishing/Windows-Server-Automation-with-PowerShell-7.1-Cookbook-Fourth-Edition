# 3.1 - Exploring Compatibility with Windows PowerShell
#
# Run on SRV1 after installing PowerShell 7

# 1. Ensuring PowerShell Remoting is fully enabled
Enable-PSRemoting -Force -WarningAction SilentlyContinue |
  Out-Null

# 2. Get Session using endpoint for Windows PowerShell 5.1
$SHT1 = @{
  ComputerName      = 'localhost'
  ConfigurationName = 'microsoft.powershell'
}
$SWP51 = New-PSSession @SHT1

# 3. Get Session using PowerShell 7.1 endpoint
$CNFName = Get-PSSessionConfiguration | 
             Where-Object PSVersion -eq '7.1' |
               Select-Object -Last 1
$SHT2 = @{
  ComputerName      = 'localhost'
  ConfigurationName = $CNFName.Name
}               
$SP71    = New-PSSession @SHT2          

# 4. Defining a script block to view default module paths
$SBMP = {
  $PSVersionTable
  $env:PSModulePath -split ';'
}

# 5. Reviewing paths in Windows PowerShell 5.1
Invoke-Command -ScriptBlock $SBMP -Session $SWP51

# 6. Reviewing paths in PowerShell 7.1
Invoke-Command -ScriptBlock $SBMP -Session $SP71


# 7. Creating a script block to get commands
$SBC = {
  $ModPaths = $Env:PSModulePath -split ';'
  $CMDS = @()
  Foreach ($ModPath in $ModPaths) {
    if (!(Test-Path $Modpath)) {Continue}
    # Process modules found in an existing module path
    $Mods = Get-ChildItem -Path $ModPath -Directory
    foreach ($Mod in $Mods){
      $Name  = $Mod.Name
      $CMDS  += Get-Command -Module $Name
    }
  }
  $CMDS  # return all commands discovered
}

# 8. Discovering all 7.1 cmdlets
$CMDS71 = Invoke-Command -ScriptBlock $SBC -Session $SP71 | 
            Where-Object CommandType -eq 'Cmdlet'
"Total commands available in PowerShell 7.1 [{0}]" -f $Cmds71.Count

# 9. Discovering all 5.1 cmdlets
$CMDS51 = Invoke-Command -ScriptBlock $SBC -Session $SWP51 |
            Where-Object CommandType -eq 'Cmdlet'
"Total commands available in PowerShell 5.1 [{0}]" -f $Cmds51.count

# 10. Creating arrays of just cmdlet names
$Commands51 = $CMDS51 | 
  Select-Object -ExpandProperty Name |
    Sort-Object -Unique
$Commands71 = $CMDS71 |
  Select-Object -ExpandProperty Name |
    Sort-Object -Unique

# 11. Discovering new cmdlets in PowerShell 7.1
Compare-Object $Commands51 $Commands71  | 
  Where-Object SideIndicator -match '^=>'  

#  12. Creating a script block to check core modules
$CMSB = {
  $M = Get-Module -Name 'Microsoft.PowerShell*' -ListAvailable
  $M
  "$($M.count) modules found in $($PSVersionTable.PSVersion)"
}

# 13. Viewing core modules in Windows PowerShell 5.1
Invoke-Command -Session $SWP51 -ScriptBlock $CMSB 

# 14. Viewing core modules in PowerShell 7.1
Invoke-Command -Session $SP71 -ScriptBlock $CMSB 

