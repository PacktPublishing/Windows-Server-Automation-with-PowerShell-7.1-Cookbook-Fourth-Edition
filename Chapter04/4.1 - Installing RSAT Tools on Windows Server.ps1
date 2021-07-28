# Recipe 4.1 - Installing RSAT Tools on Windows Server
#
# Uses SRV1

# Run From SRV1


# 1. Displaying counts of available PowerShell commands
$CommandsBeforeRSAT = Get-Command 
$CmdletsBeforeRSAT = $CommandsBeforeRSAT  |
    Where-Object CommandType -eq 'Cmdlet'
$CommandCountBeforeRSAT = $CommandsBeforeRSAT.Count
$CmdletCountBeforeRSAT  = $CmdletsBeforeRSAT.Count
"On Host: [$(hostname)]"
"Total Commands available before RSAT installed [$CommandCountBeforeRSAT]"
"Cmdlets available before RSAT installed        [$CmdletCountBeforeRSAT]"

# 2. Getting command types returned by Get-Command
$CommandsBeforeRSAT | 
  Group-Object -Property CommandType

# 3. Checking the object type details
$CommandsBeforeRSAT | 
  Get-Member |
    Select-Object -ExpandProperty TypeName -Unique

# 4. Getting the collection of PowerShell modules and a count of 
#    modules before adding the RSAT tools
$ModulesBefore = Get-Module -ListAvailable 

# 5. Displaying a count of modules available
#    before adding the RSAT tools
$CountOfModulesBeforeRSAT = $ModulesBefore.Count
"$CountOfModulesBeforeRSAT modules available"

# 6. Getting a count of features actually available on SRV1
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$Features  = Get-WindowsFeature 
$FeaturesI = $Features | Where-Object Installed 
$RsatF     = $Features |
               Where-Object Name -Match 'RSAT'
$RSATFI    = $RSATF | 
              Where-Object Installed 

# 7. Displaying counts of features installed
"On Host [$(hostname)]"
"Total features available      [{0}]"  -f $Features.count
"Total features installed      [{0}]"  -f $FeaturesI.count
"Total RSAT features available [{0}]"  -f $RSATF.count
"Total RSAT features installed [{0}]"  -f $RSATFI.count

# 8. Adding ALL RSAT tools to SRV1
Get-WindowsFeature -Name *RSAT* | 
  Install-WindowsFeature

# 9. Rebooting  SRV1 then logging on as the local administrator  
Restart-Computer -Force

# 10. Getting Details of RSAT tools now installed on SRV1
$FSRV1A   = Get-WindowsFeature
$IFSRV1A  = $FSRV1A | Where-Object Installed
$RSFSRV1A = $FSRV1A | Where-Object Installed | 
              Where-Object Name -Match 'RSAT'

# 11. Displaying counts of commands after installing the RSAT tools
"After Installation of RSAT tools on SRV1"
"$($IFSRV1A.count) features installed on SRV1"
"$($RSFSRV1A.count) RSAT features installed on SRV1"

# 12. Displaying RSAT tools on SRV1
$MODS = "$env:windir\system32\windowspowerShell\v1.0\modules"
$SMMOD = "$MODS\ServerManager"
Update-FormatData -PrependPath "$SMMOD\*.format.ps1xml"
Get-WindowsFeature |
  Where-Object Name -Match 'RSAT'